auth = Cine.lib('authentication')
User = Cine.model('user')

describe 'authentication', ->

  beforeEach ->
    @app = newApp()
    @app.currentUser = new User({}, {app: @app})
    @ajaxSpy = sinon.stub(jQuery, 'ajax')

  afterEach ->
    @ajaxSpy.restore()

  describe 'login', ->
    beforeEach ->
      @form = jQuery("<form><input name='a' value='b'/></form>")

    it 'logs in a user', ->
      auth.login(@app, @form)
      ajaxArgs = @ajaxSpy.firstCall.args[0]
      expect(ajaxArgs.type).to.equal('POST')
      expect(ajaxArgs.url).to.equal('/login')
      expect(ajaxArgs.data).to.equal('a=b')
      ajaxArgs.success(id: 'some id', name: 'New logged in name', email: 'the email')
      expect(@app.currentUser.isLoggedIn()).to.be.true
      expect(@app.currentUser.attributes.name).to.equal('New logged in name')

    it 'might need the user to complete to signup', (done)->
      auth.login(@app, @form, completeSignup: done)
      ajaxArgs = @ajaxSpy.firstCall.args[0]
      expect(ajaxArgs.type).to.equal('POST')
      expect(ajaxArgs.url).to.equal('/login')
      expect(ajaxArgs.data).to.deep.equal('a=b')
      ajaxArgs.success(id: 'some id')
      expect(@app.currentUser.isLoggedIn()).to.be.false

    it 'takes a success callback', (done)->
      auth.login(@app, @form, success: done)
      ajaxArgs = @ajaxSpy.firstCall.args[0]
      ajaxArgs.success(id: 'my id', name: 'New logged in name', email: 'the email')

    it 'takes an error callback', (done)->
      auth.login(@app, @form, error: (err)->
        expect(err).to.equal('abc')
        done()
      )
      ajaxArgs = @ajaxSpy.firstCall.args[0]
      ajaxArgs.error(responseText: 'abc')

  describe 'logout', ->
    beforeEach ->
      @app.currentUser.set(id: 'some id', name: 'my Name')
      expect(@app.currentUser.isLoggedIn()).to.be.true

    it 'logs out the user', ->
      auth.logout(@app)
      ajaxArgs = @ajaxSpy.firstCall.args[0]
      expect(ajaxArgs.type).to.equal('GET')
      expect(ajaxArgs.url).to.equal('/logout')
      ajaxArgs.success()
      expect(@app.currentUser.isLoggedIn()).to.be.false

    it 'takes a success callback', (done)->
      auth.logout(@app, success: done)
      ajaxArgs = @ajaxSpy.firstCall.args[0]
      ajaxArgs.success()

    it 'takes an error callback', (done)->
      auth.logout(@app, error: done)
      ajaxArgs = @ajaxSpy.firstCall.args[0]
      ajaxArgs.error()

  describe 'updateAccount', ->
    beforeEach ->
      @form = jQuery("<form><input name='a' value='b'/></form>")

    it 'calls to update the account', ->
      auth.updateAccount(@app, @form)
      ajaxArgs = @ajaxSpy.firstCall.args[0]
      expect(ajaxArgs.type).to.equal('POST')
      expect(ajaxArgs.url).to.equal('/api/1/-/update-account')
      expect(ajaxArgs.data).to.deep.equal('a=b')
      ajaxArgs.success(id: 'my id', name: 'New logged in name')
      expect(@app.currentUser.isLoggedIn()).to.be.true
      expect(@app.currentUser.attributes.name).to.equal('New logged in name')

    it 'takes a success callback', (done)->
      auth.updateAccount(@app, @form, success: done)
      ajaxArgs = @ajaxSpy.firstCall.args[0]
      ajaxArgs.success(id: 'my id', name: 'New logged in name')

    it 'takes an error callback', (done)->
      auth.updateAccount(@app, @form, error: (message)->
        expect(message).to.equal('123')
        done()
      )
      ajaxArgs = @ajaxSpy.firstCall.args[0]
      ajaxArgs.error(responseText: JSON.stringify(message: '123'))

  describe 'forgotPassword', ->
    beforeEach ->
      @form = jQuery("<form><input name='a' value='b'/></form>")

    it 'calls to forgot-password', ->
      auth.forgotPassword(@app, @form)
      ajaxArgs = @ajaxSpy.firstCall.args[0]
      expect(ajaxArgs.type).to.equal('POST')
      expect(ajaxArgs.url).to.equal('/api/1/-/password-change-request')
      expect(ajaxArgs.data).to.equal('a=b')
      ajaxArgs.success()

    it 'takes a success callback', (done)->
      auth.forgotPassword(@app, @form, success: done)
      ajaxArgs = @ajaxSpy.firstCall.args[0]
      ajaxArgs.success()

    it 'takes an error callback', (done)->
      auth.forgotPassword(@app, @form, error: done)
      ajaxArgs = @ajaxSpy.firstCall.args[0]
      ajaxArgs.error()

  describe 'updatePassword', ->
    beforeEach ->
      @form = jQuery("<form><input name='a' value='b'/></form>")
      global.window = location: {}

    afterEach ->
      delete global.window

    it 'calls to update-password and redirects', ->
      auth.updatePassword(@app, @form)
      ajaxArgs = @ajaxSpy.firstCall.args[0]
      expect(ajaxArgs.type).to.equal('post')
      expect(ajaxArgs.url).to.equal('/update-password')
      expect(ajaxArgs.data).to.equal('a=b')
      ajaxArgs.success(redirect: 'url to go to')
      expect(global.window.location.href).to.equal('url to go to')

    it 'takes a success callback', (done)->
      auth.updatePassword(@app, @form, success: done)
      ajaxArgs = @ajaxSpy.firstCall.args[0]
      ajaxArgs.success(redirect: 'url to go to')

    it 'takes an error callback', (done)->
      auth.updatePassword(@app, @form, error: done)
      ajaxArgs = @ajaxSpy.firstCall.args[0]
      ajaxArgs.error()
