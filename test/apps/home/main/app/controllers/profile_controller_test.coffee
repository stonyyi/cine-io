ProfileController = Cine.controller 'profile'
ControllerTester = Cine.require('test/helpers/test_controller_action')
AssertTitleAndDescription = Cine.require('test/helpers/assert_title_and_description')
test = ControllerTester(ProfileController)

describe 'ProfileController', ->
  beforeEach ->
    ProfileController.app = mainApp

  AssertTitleAndDescription ProfileController

  afterEach ->
    delete ProfileController.app

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
