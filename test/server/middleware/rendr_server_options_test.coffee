app = Cine.require('app').app
rendrServerOptions = Cine.middleware('rendr_server_options', app)
_ = require('underscore')

describe 'rendrServerOptions', ->
  describe 'appData',  ->

    beforeEach ->
      @appData = rendrServerOptions.appData

    it 'includes the environment', ->
      expect(@appData.env).to.equal(app.settings.env)
      expect(app.settings.env).to.equal("test")

    it 'does not include mixpanel secrets', ->
      mixpanelKeys = _.keys(@appData.mixpanel)
      expect(mixpanelKeys).to.deep.equal(['tracking_id'])

    it 'does not include google analytics secrets', ->
      googleAnalyticsKeys = _.keys(@appData.google_analytics)
      expect(googleAnalyticsKeys).to.deep.equal(['domain', 'tracking_id'])

    it 'does not include stripe secrets', ->
      stripeKeys = _.keys(@appData.stripe)
      expect(stripeKeys).to.deep.equal(['publishableKey'])
