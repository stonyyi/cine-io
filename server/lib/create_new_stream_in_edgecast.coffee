request = require('request')
moment = require('moment')
async = require('async')
_ = require('underscore')

EdgecastStream = Cine.server_model('edgecast_stream')

edgecastConfig = Cine.config('variables/edgecast')
edgecastToken = edgecastConfig.token
edgecastAccount = edgecastConfig.account
# https://my.edgecast.com/uploads/ubers/1/docs/en-US/webhelp/b/RESTAPIHelpCenter/default.htm
hlsHdsUrl = "https://api.edgecast.com/v2/mcc/customers/#{edgecastAccount}/httpstreaming/livehlshds"
flashMediaStreamingUrl = "https://api.edgecast.com/v2/mcc/customers/#{edgecastAccount}/fmsliveauth/streamkeys"

prefix = "cine"
instanceName = "#{prefix}s"
passwordDictionary = ["go", "world", "earth", "music", "notes", "band", "group", "fans", "rock", "tune", "creative", "piano", "guitar", "drums", "song", "violin", "cello", "harp", "trumpet", "keyboard", "treble", "bass", "cleff", "chord", "encore", "harmony", "major", "minor", "pitch", "prelude", "sharp"]

generatePassword = (callback)->
  d = new Date
  seconds = d.getSeconds()
  randomPassword = _.sample passwordDictionary
  randomPassword = "#{randomPassword}#{seconds}"
  callback null, randomPassword

expirationDate = (callback)->
  d = new Date
  d.setFullYear(d.getFullYear() + 20)
  callback(null, moment(d).format('YYYY-MM-DD'))

createStream = (response, originalCallback)->
  stageName = "#{prefix}#{response.getEdgecastStreamCount+1}"
  stream = new EdgecastStream
    instanceName: instanceName
    expiration: response.expirationDate
    eventName: stageName
    streamName: stageName
    streamKey: response.generatePassword

  createHlsHdsUrl = (callback)->
    newHlsHdsOptions =
      KeyFrameInterval: 3
      Expiration: response.expirationDate
      EventName: stream.eventName
      InstanceName: stream.instanceName

    requestOptions =
      url: hlsHdsUrl
      headers:
        Authorization: "TOK:#{edgecastToken}"
      json: newHlsHdsOptions

    request.post requestOptions, (err, response, body)->
      return callback(err) if err
      return callback('not 200') if response.statusCode != 200
      response =
        id: body.Id
      callback(err, response)

  createFmsUrl = (callback)->
    newFmsLiveOptions =
      Key: stream.streamKey
      Path: "#{stream.instanceName}/#{stream.eventName}"
    requestOptions =
      url: flashMediaStreamingUrl
      headers:
        Authorization: "TOK:#{edgecastToken}"
      json: newFmsLiveOptions
    request.post requestOptions, callback

  saveEdgecastStream = (err, response)->
    return originalCallback(err) if err
    stream.edgecastId = response.createHlsHdsUrl.id
    stream.save originalCallback

  postToEdgecastAsyncOptions =
    createHlsHdsUrl: createHlsHdsUrl
    createFmsUrl: createFmsUrl
  async.parallel postToEdgecastAsyncOptions, saveEdgecastStream

module.exports = (originalCallback)->

  prepareCreateStreamAsyncOptions =
    getEdgecastStreamCount: (callback)->
      EdgecastStream.count instanceName: instanceName, callback
    generatePassword: generatePassword
    expirationDate: expirationDate

  async.parallel prepareCreateStreamAsyncOptions, (err, response)->
    return originalCallback(err) if err
    createStream(response, originalCallback)
