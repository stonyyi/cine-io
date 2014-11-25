_ = require('underscore')
module.exports = (Controller, options={})->
  _.defaults options,
    title: "cine.io: live video with RTC, RTMP, and HLS; APIs and SDKs for iOS, Android, and the web."
    description: "Build powerful iOS and Android native or web-based video apps using our APIs and SDKs for RTC, RTMP, and HLS."

  beforeEach ->
    @setStub = sinon.stub Controller.app, 'set'

  afterEach ->
    expect(@setStub.calledTwice).to.be.true
    expect(@setStub.firstCall.args).to.have.length(2)
    expect(@setStub.firstCall.args[0]).to.equal('title')
    expect(@setStub.firstCall.args[1]).to.equal(options.title)
    expect(@setStub.secondCall.args).to.have.length(2)
    expect(@setStub.secondCall.args[0]).to.equal('description')
    expect(@setStub.secondCall.args[1]).to.equal(options.description)

  afterEach ->
    @setStub.restore()
