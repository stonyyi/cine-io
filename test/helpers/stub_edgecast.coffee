request = require('request')
moment = require('moment')
async = require('async')
edgecastToken = Cine.config('variables/edgecast').token
EdgecastStream = Cine.model('edgecast_stream')

module.exports = ->
  expectAuthorization = (options)->
    expect(options.headers.Authorization).to.equal("TOK:#{edgecastToken}")

  validateHlsOptions = (options, callback)->
    d = new Date
    d.setFullYear(d.getFullYear() + 20)
    expectedOptions =
      KeyFrameInterval: 3
      Expiration: moment(d).format('YYYY-MM-DD')
      EventName: 'cine2'
      InstanceName: 'cines'
    expect(options.json).to.deep.equal(expectedOptions)
    expectAuthorization(options)
    callback(null, {statusCode: 200}, {Id: 123})

  validateFmsOptions = (options, callback)->
    expect(options.json.Path).to.equal('cines/cine2')
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

  afterEach (done)->
    foundAStream = false
    testFunction = -> foundAStream
    checkFunction = (callback)->
      EdgecastStream.findOne streamName: 'cine2', (err, stream)->
        foundAStream = stream
        callback()

    async.until testFunction, checkFunction, done

  afterEach ->
    request.post.restore()
