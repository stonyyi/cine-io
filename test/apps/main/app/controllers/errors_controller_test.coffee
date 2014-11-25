ErrorsController = Cine.controller('errors')
_ = require('underscore')
ControllerTester = Cine.require('test/helpers/test_controller_action')
AssertTitleAndDescription = Cine.require('test/helpers/assert_title_and_description')
test = ControllerTester(ErrorsController)

describe 'ErrorsController', ->
  actions = ['not_found', 'unauthorized', 'server_error']
  _.each actions, (action)->
    describe "##{action}", ->

      beforeEach ->
        ErrorsController.app = mainApp

      AssertTitleAndDescription ErrorsController

      afterEach ->
        delete ErrorsController.app

      it "calls back", (done)->
        params = {}
        callback = (err, viewOptions)->
          expect(err).to.equal(undefined)
          done()
        test(action, params, callback)
