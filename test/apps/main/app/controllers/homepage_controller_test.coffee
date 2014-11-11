HomepageController = Cine.controller('homepage')
ControllerTester = Cine.require('test/helpers/test_controller_action')
test = ControllerTester(HomepageController)

describe 'HomepageController', ->
  describe '#show', ->
    it "calls back", (done)->
      params = {}
      callback = (err, viewOptions)->
        expect(err).to.equal(undefined)
        done()
      test('show', params, callback)

  describe '#products', ->
    it "calls back", (done)->
      params = {}
      callback = (err, viewOptions)->
        expect(err).to.equal(undefined)
        done()
      test('products', params, callback)

  describe '#solutions', ->
    it "calls back", (done)->
      params = {}
      callback = (err, viewOptions)->
        expect(err).to.equal(undefined)
        done()
      test('solutions', params, callback)

  describe '#pricing', ->
    it "calls back", (done)->
      params = {}
      callback = (err, viewOptions)->
        expect(err).to.equal(undefined)
        done()
      test('pricing', params, callback)
