setTitleAndDescription = Cine.lib('set_title_and_description')

describe 'setTitleAndDescription', ->
  beforeEach ->
    @app = {set: ->}
    @setStub = sinon.stub @app, 'set'

  afterEach ->
    @setStub.restore()

  expectSetStub = (title, description)->
    expect(@setStub.calledTwice).to.be.true
    expect(@setStub.firstCall.args).to.have.length(2)
    expect(@setStub.firstCall.args[0]).to.equal('title')
    expect(@setStub.firstCall.args[1]).to.equal(title)
    expect(@setStub.secondCall.args).to.have.length(2)
    expect(@setStub.secondCall.args[0]).to.equal('description')
    expect(@setStub.secondCall.args[1]).to.equal(description)

  it 'has defaults', ->
    setTitleAndDescription(@app)
    expectSetStub.call this,
      "cine.io: live video with RTC, RTMP, and HLS; APIs and SDKs for iOS, Android, and the web."
      "Build powerful iOS and Android native or web-based video apps using our APIs and SDKs for RTC, RTMP, and HLS."

  it 'takes options', ->
    setTitleAndDescription(@app, title: 'new title', description: 'new description')
    expectSetStub.call this,
      "new title"
      "new description"
