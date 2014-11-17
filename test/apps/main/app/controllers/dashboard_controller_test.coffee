DashboardController = Cine.controller 'dashboard'
ControllerTester = Cine.require('test/helpers/test_controller_action')
test = ControllerTester(DashboardController)

describe 'DashboardController', ->
  beforeEach ->
    DashboardController.app = mainApp

  afterEach ->
    delete DashboardController.app

  describe '#show', ->
    it 'requires a current user', (done)->
      params = {}
      callback = (err, viewOptions)->
        expect(err.status).to.equal(401)
        done()
      test('show', params, callback)

    describe 'with a current user', ->
      beforeEach ->
        mainApp.currentUser.set(id: 'my id', masterKey: 'the master key')

      afterEach ->
        mainApp.currentUser.clear()

      it 'goes through', (done)->
        params = {}
        callback = (err, result)->
          expect(err).to.be.undefined
          expect(result).to.be.undefined
          done()
        test('show', params, callback)
