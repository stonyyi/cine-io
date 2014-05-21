request = require('request')
moment = require('moment')
async = require('async')
_ = require('underscore')

EdgecastStream = Cine.server_model('edgecast_stream')

edgecastConfig = Cine.config('variables/edgecast')
edgecastToken = edgecastConfig.token
edgecastAccount = edgecastConfig.account
# https://my.edgecast.com/uploads/ubers/1/docs/en-US/webhelp/b/RESTAPIHelpCenter/default.htm
streamKeysUrl = "https://api.edgecast.com/v2/mcc/customers/#{edgecastAccount}/fmsliveauth/streamkeys"
hlsEndpointUrl = "https://api.edgecast.com/v2/mcc/customers/#{edgecastAccount}/httpstreaming/livehlshds"

expectedFields = ["edgecastId", "eventName", "expiration", "instanceName", "streamKey", "streamName"]

edgecastStreamHasAllData = (streamInDb, edgecastData)->
  _.all edgecastData, (value, field)->
    _.isEqual(streamInDb[field], value)

ensureEdgecastStream = (streamData, callback)->
  unless _.isEqual(_.keys(streamData).sort(), expectedFields)
    console.log('stream data missing fields', expectedFields, _.keys(streamData).sort())
    return callback()
  params = _.pick(streamData, 'eventName', 'instanceName', 'streamKey', 'streamName')
  EdgecastStream.findOne params, (err, edgecastStream)->
    return callback(err) if err
    if edgecastStream
      if edgecastStreamHasAllData(edgecastStream, streamData)
        console.log('stream good', _.pick(streamData, 'streamName', 'instanceName')
        return callback()
      console.log('new data', streamData)
      edgecastStream.set streamData
      edgecastStream.save callback
    else
      console.log('new stream', streamData)
      stream = new EdgecastStream streamData
      stream.save callback

ensureEdgecastStreamsInMongo = (edgecastStreamInstanceData, callback)->
  async.each edgecastStreamInstanceData, ensureEdgecastStream, callback

streamKeyResponseItemToEdgecastInfo = (streamKeyResponseItem)->
  parts = streamKeyResponseItem.Path.split('/')
  data =
    instanceName: parts[0]
    streamName: parts[1]
    streamKey: streamKeyResponseItem.Key
  data

findEdgecastHlsEndpointFromStreamKey = (edgecastHlsResponses, streamKeyData)->
  _.find edgecastHlsResponses, (hlsEndpoint)->
    hlsEndpoint.EventName == streamKeyData.streamName &&
    hlsEndpoint.InstanceName == streamKeyData.instanceName

findStreamKeyFromHlsEndpoint = (edgecastStreamsData, hlsEndpoint)->
  _.find edgecastStreamsData, (edgecastStreamData)->
    hlsEndpoint.EventName == edgecastStreamData.eventName &&
    hlsEndpoint.InstanceName == edgecastStreamData.instanceName

ensureNoLonelyHlsEndpoints = (fromStreamKeysToEdgecastData, hlsEndpoints)->
  chain = _.chain(hlsEndpoints).reject (hlsEndpoint)->
    findStreamKeyFromHlsEndpoint(fromStreamKeysToEdgecastData, hlsEndpoint)?
  chain.each (hlsEndpoint)->
    dataToShow = _.pick(hlsEndpoint, 'Id', 'EventName', 'InstanceName')
    console.warn("Lonely hls endpoint", dataToShow)

ensureNoLonelyFMSEndpoints = (fromStreamKeysToEdgecastData)->
  chain = _.chain(fromStreamKeysToEdgecastData).reject (edgecastStreamData)->
    edgecastStreamData.eventName?

  chain.each (fmsEndpoint)->
    dataToShow = _.pick(fmsEndpoint, 'streamName', 'streamKey')
    console.warn("Lonely FMS endpoint", dataToShow)

ensureNoLonelyHlsEndpointsOrFMSEndpoints = (fromStreamKeysToEdgecastData, hlsEndpoints)->
  ensureNoLonelyHlsEndpoints(fromStreamKeysToEdgecastData, hlsEndpoints)
  ensureNoLonelyFMSEndpoints(fromStreamKeysToEdgecastData)

mergeResponses = (edgecastCallResponses)->
  fromStreamKeysToEdgecastData = _.map edgecastCallResponses.streamKeyData, (streamData)->
    edgecastStreamData = streamKeyResponseItemToEdgecastInfo(streamData)
    # console.log('streamKeyData', edgecastStreamData)
    edgecastHlsEndpoint = findEdgecastHlsEndpointFromStreamKey(edgecastCallResponses.hlsEndpoints, edgecastStreamData)
    # console.log('edgecastHlsEndpoint', edgecastHlsEndpoint)
    return edgecastStreamData unless edgecastHlsEndpoint
    edgecastStreamData.eventName = edgecastHlsEndpoint.EventName
    edgecastStreamData.expiration = new Date(edgecastHlsEndpoint.Expiration)
    edgecastStreamData.edgecastId = edgecastHlsEndpoint.Id
    edgecastStreamData
  # this will ensure all stream keys have a corresponding hls endpoint
  # we need to go the other way to ensure no lonely hls endpoints
  ensureNoLonelyHlsEndpointsOrFMSEndpoints(fromStreamKeysToEdgecastData, edgecastCallResponses.hlsEndpoints)
  fromStreamKeysToEdgecastData

fetchEdgecastUrl = (url, callback)->
  requestOptions =
    url: url
    headers:
      Authorization: "TOK:#{edgecastToken}"

  request.get requestOptions, (err, response, body)->
    return callback(err) if err
    return callback('not 200') if response.statusCode != 200
    callback(null, JSON.parse(body))

fetchStreamKeys = (callback)->
  fetchEdgecastUrl streamKeysUrl, callback

fetchHlsEndpoints = (callback)->
  fetchEdgecastUrl hlsEndpointUrl, callback

module.exports = (originalCallback)->
  fetchEdgecastUrls =
    streamKeyData: fetchStreamKeys
    hlsEndpoints: fetchHlsEndpoints

  async.parallel fetchEdgecastUrls, (err, response)->
    return originalCallback(err) if err
    edgecastStreamInstanceData = mergeResponses(response)
    ensureEdgecastStreamsInMongo(edgecastStreamInstanceData, originalCallback)
