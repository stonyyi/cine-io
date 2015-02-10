class FakeHttpGetEndpoint
  constructor: (@options)->
    sinon.spy this, 'getUrl'
  getUrl: (callback)->
    callback(null, "http://some-kurento-url/some-id")
class FakeWebRtcEndpoint
  constructor: (@options)->
    sinon.spy this, 'connect'
    sinon.spy this, 'processOffer'
  connect: (endpoint, callback)->
    expect(endpoint instanceof FakeHttpGetEndpoint).to.be.true
    callback()
  processOffer: (offer, callback)->
    callback(null, "some answer")

class FakeKurentoPipeline
  constructor: ->
    sinon.spy this, 'create'
    sinon.spy this, 'release'
  release: ->
  create: (name, options, callback)->
    if typeof options == 'function'
      callback = options
      options = {}
    return switch name
      when 'HttpGetEndpoint'
        callback(null, new FakeHttpGetEndpoint(options))
      when 'WebRtcEndpoint'
        callback(null, new FakeWebRtcEndpoint(options))
      else
        callback("unknown type")

class FakeKurento
  constructor: ->
    sinon.spy this, 'create'
  create: (thing, callback)->
    expect(thing).to.equal("MediaPipeline")
    callback(null, new FakeKurentoPipeline)

exports.FakeHttpGetEndpoint = FakeHttpGetEndpoint
exports.FakeKurentoPipeline = FakeKurentoPipeline
exports.FakeWebRtcEndpoint = FakeWebRtcEndpoint
exports.FakeKurento = FakeKurento
