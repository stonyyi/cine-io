tracker = Cine.lib('tracker')
User = Cine.model('user')

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
      global.mixpanel = {track: sinon.stub(), identify: sinon.stub(), alias: sinon.stub(), people: {set: sinon.stub()}}
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
      it 'identifies in mixpanel for old users', ->
        d = new Date
        d.setHours(d.getHours() - 1)
        c = new User(createdAt: d.toISOString(), id: '123')
        tracker.logIn(c)
        expect(tracker.mixpanel.identify.calledOnce).to.be.true
        expect(tracker.mixpanel.alias.called).to.be.false
        expect(tracker.mixpanel.identify.firstCall.args).to.deep.equal(['123'])

      it 'aliases and identifies in mixpanel for new users', ->
        c = new User(createdAt: new Date, id: '123')
        tracker.logIn(c)
        expect(tracker.mixpanel.alias.calledOnce).to.be.true
        expect(tracker.mixpanel.identify.calledOnce).to.be.true
        expect(tracker.mixpanel.alias.firstCall.args).to.deep.equal(['123'])
        expect(tracker.mixpanel.identify.firstCall.args).to.deep.equal(['123'])

      it 'will trigger a signup on a new user', ->
        c = new User(createdAt: new Date, id: '123')
        tracker.logIn(c)
        assertGA('userSignup')
        assertMixpanel('userSignup')


      it 'updates the mixpanel person', ->
        c = new User(plan: 'test', email: 'the email', name: 'the name', createdAt: new Date, id: '123')
        tracker.logIn(c)
        expect(mixpanel.people.set.calledOnce).to.be.true
        expect(mixpanel.people.set.firstCall.args).to.deep.equal([{Plan: 'test', $email: 'the email', $name: 'the name'}])

    describe '#logOut', ->
      it 'clears the mixpanel cookie if there is one', ->
        expect(tracker.logOut).to.not.throw(Error)

      it 'clears the mixpanel cookie if there is one', ->
        mixpanel.cookie = clear: sinon.stub()
        tracker.logOut()
        expect(tracker.mixpanel.cookie.clear.calledOnce).to.be.true

    describe '#userSignup', ->
      beforeEach ->
        tracker.userSignup()

      it 'sends a ga event', ->
        assertGA('userSignup')

      it 'sends a mixpanel event', ->
        assertMixpanel('userSignup')

    describe '#addedCard', ->
      beforeEach ->
        tracker.addedCard()

      it 'sends a ga event', ->
        assertGA('addedCard')

      it 'sends a mixpanel event', ->
        assertMixpanel('addedCard')

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

    describe '#planChange', ->
      beforeEach ->
        tracker.planChange('test')

      it 'does not send a ga event', ->
        expect(global.ga.called).to.be.false

      it 'sends a mixpanel event', ->
        assertMixpanel('planChange', plan: 'test')
