HomepageController = Cine.controller('homepage')
ControllerTester = Cine.require('test/helpers/test_controller_action')
AssertTitleAndDescription = Cine.require('test/helpers/assert_title_and_description')
test = ControllerTester(HomepageController)

describe 'HomepageController', ->
  beforeEach ->
    HomepageController.app = mainApp

  AssertTitleAndDescription HomepageController

  afterEach ->
    delete HomepageController.app

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

  describe '#pricing', ->
    it "calls back", (done)->
      params = {}
      callback = (err, viewOptions)->
        expect(err).to.equal(undefined)
        done()
      test('pricing', params, callback)
