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
      global.mixpanel = {track: sinon.stub()}
      tracker.preventTracking = false
      tracker.load()

    afterEach ->
      tracker.unload()
      tracker.preventTracking = true
      delete global.ga
      delete global.mixpanel

    gaArgs = ->
      global.ga.firstCall.args

    mixpanelArgs = ->
      global.mixpanel.track.firstCall.args

    assertGA = (eventName, data={})->
      expect(global.ga.calledOnce).to.be.true
      args = gaArgs()
      expect(args[0]).to.equal('send')
      expectedGAArgs =
        hitType: 'event'
        eventCategory: 'KPI'
        eventAction: eventName
      expectedGAArgs.eventValue = data.value if data.value
      expect(args[1]).to.deep.equal(expectedGAArgs)

    assertMixpanel = (eventName, data={})->
      expect(global.mixpanel.track.calledOnce).to.be.true
      args = mixpanelArgs()
      expect(args[0]).to.equal(eventName)
      expect(args[1]).to.deep.equal(data)


    describe '#logIn', ->
      it 'is tested'

    describe '#userSignup', ->
      beforeEach ->
        tracker.userSignup()

      it 'sends a ga event', ->
        assertGA('userSignup')

      it 'sends a mixpanel event', ->
        assertMixpanel('userSignup')

    describe '#getApiKey', ->
      beforeEach ->
        tracker.getApiKey(value: 12)

      it 'sends a ga event', ->
        assertGA('getApiKey', value: 12)

      it 'sends a mixpanel event', ->
        assertMixpanel('getApiKey', value: 12)

    describe '#startedDemo', ->
      beforeEach ->
        tracker.startedDemo()

      it 'does not send a ga event', ->
        expect(global.ga.called).to.be.false

      it 'sends a mixpanel event', ->
        assertMixpanel('startedDemo')
