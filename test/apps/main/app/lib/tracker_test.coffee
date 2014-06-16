tracker = Cine.lib('tracker')

describe 'tracker', ->
  describe '#load', ->
    it 'does not set when there is no global ga', ->
      expect(tracker.ga).to.be.undefined
      tracker.load()
      expect(tracker.ga).to.be.undefined

    it 'sets when there is a global ga', ->
      expect(tracker.ga).to.be.undefined
      global.ga = "HEY"
      tracker.load()
      expect(tracker.ga).to.equal("HEY")
      delete global.ga
      tracker.unload()

  describe 'trackingEventsOnServer', ->
    it 'throws an exception when tracking on the server', ->
      expect(tracker.userSignup).to.throw('cannot track events on server')

    it 'has an override', ->
      tracker.preventTracking = false
      expect(tracker.userSignup).not.to.throw('cannot track events on server')
      tracker.preventTracking = true

  describe 'trackingEvents', ->
    beforeEach ->
      global.ga = sinon.stub()
      tracker.preventTracking = false
      tracker.load()

    afterEach ->
      tracker.unload()
      tracker.preventTracking = true
      delete global.ga
    gaArgs = ->
      global.ga.firstCall.args

    describe '#userSignup', ->
      it 'sends a ga event', ->
        tracker.userSignup()
        expect(global.ga.calledOnce).to.be.true
        args = gaArgs()
        expect(args[0]).to.equal('send')
        expect(args[1]).to.deep.equal(hitType: 'event', eventCategory: 'KPI', eventAction: 'userSignup')

    describe '#getApiKey', ->
      it 'sends a ga event', ->
        tracker.getApiKey(value: 12)
        expect(global.ga.calledOnce).to.be.true
        args = gaArgs()
        expect(args[0]).to.equal('send')
        expect(args[1]).to.deep.equal(hitType: 'event', eventCategory: 'KPI', eventAction: 'getApiKey', eventValue: 12)
