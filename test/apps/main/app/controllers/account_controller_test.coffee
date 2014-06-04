AccountController = Cine.controller 'account'
ControllerTester = Cine.require('test/helpers/test_controller_action')
test = ControllerTester(AccountController)

describe 'AccountController', ->
  beforeEach ->
    AccountController.app = mainApp

  afterEach ->
    delete AccountController.app

  describe '#edit', ->
    it 'requires a current user', (done)->
      params = {}
      callback = (err, viewOptions)->
        expect(err.status).to.equal(401)
        done()
      test('edit', params, callback)

    describe 'with a current user', ->
      beforeEach ->
        mainApp.currentUser.set(id: 'my id')

      afterEach ->
        mainApp.currentUser.clear()

      it 'completes when logged in', (done)->
        params = {}
        callback = (err, viewOptions)->
          expect(err).to.equal(undefined)
          done()
        test('edit', params, callback)
