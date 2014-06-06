request = require('request')
moment = require('moment')
async = require('async')
_ = require('underscore')
shortId = require('shortid')
edgecastToken = Cine.config('variables/edgecast').token
EdgecastStream = Cine.server_model('edgecast_stream')

module.exports = (createOptions={})->
  _.defaults(createOptions, streamName: 'rndstream')
  expectAuthorization = (options)->
    expect(options.headers.Authorization).to.equal("TOK:#{edgecastToken}")

  validateHlsOptions = (options, callback)->
    d = new Date
    d.setFullYear(d.getFullYear() + 20)
    expectedOptions =
      KeyFrameInterval: 3
      Expiration: moment(d).format('YYYY-MM-DD')
      EventName: createOptions.streamName
      InstanceName: 'cines'
    expect(options.json).to.deep.equal(expectedOptions)
    expectAuthorization(options)
    callback(null, {statusCode: 200}, {Id: 123})

  validateFmsOptions = (options, callback)->
    expect(options.json.Path).to.equal("cines/#{createOptions.streamName}")
    expect(options.json.Key).to.have.length.above(1)
    expectAuthorization(options)
    callback(null, statusCode: 200)

  requestResponseHandler = (options, callback)->
    if options.url == 'https://api.edgecast.com/v2/mcc/customers/C45E/httpstreaming/livehlshds'
      validateHlsOptions(options, callback)
    else if options.url == 'https://api.edgecast.com/v2/mcc/customers/C45E/fmsliveauth/streamkeys'
      validateFmsOptions(options, callback)
    else
      throw new Error('broken')

  beforeEach ->
    sinon.stub request, 'post', requestResponseHandler
    sinon.stub(shortId, 'generate').returns(createOptions.streamName)

  afterEach (done)->
    foundAStream = false
    testFunction = -> foundAStream
    checkFunction = (callback)->
      EdgecastStream.findOne streamName: createOptions.streamName, (err, stream)->
        foundAStream = stream
        callback()

    async.until testFunction, checkFunction, done

  afterEach ->
    request.post.restore()
    shortId.generate.restore()
