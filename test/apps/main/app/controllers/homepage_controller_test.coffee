HomepageController = GS.controller('homepage')
ControllerTester = GS.require('test/helpers/test_controller_action')
test = ControllerTester(HomepageController)

describe 'HomepageController', ->
  describe '#show', ->
    it "calls back", (done)->
      params = {}
      callback = (err, viewOptions)->
        expect(err).to.equal(undefined)
        done()
      test('show', params, callback)
