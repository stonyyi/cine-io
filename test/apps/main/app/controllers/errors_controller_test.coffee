ErrorsController = Cine.controller('errors')
_ = require('underscore')
ControllerTester = Cine.require('test/helpers/test_controller_action')
test = ControllerTester(ErrorsController)

describe 'ErrorsController', ->
  actions = ['not_found', 'unauthorized', 'server_error']
  _.each actions, (action)->
    describe "##{action}", ->
      it "calls back", (done)->
        params = {}
        callback = (err, viewOptions)->
          expect(err).to.equal(undefined)
          done()
        test(action, params, callback)
