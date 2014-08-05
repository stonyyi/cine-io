BillingController = Cine.controller 'billing'
ControllerTester = Cine.require('test/helpers/test_controller_action')
test = ControllerTester(BillingController)

describe 'BillingController', ->
  beforeEach ->
    BillingController.app = mainApp

  afterEach ->
    delete BillingController.app

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
