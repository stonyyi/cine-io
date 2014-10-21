DashboardController = Cine.controller 'dashboard', 'admin'
ControllerTester = Cine.require('test/helpers/test_controller_action')
test = ControllerTester(DashboardController)

describe 'DashboardController', ->
  beforeEach ->
    DashboardController.app = mainApp
    @fetchStub = sinon.stub mainApp, "fetch", (spec, callback)->
      expect(spec).to.deep.equal
        model: {model: 'Stats', params: {id: 'the-stats'}}
        collection: {collection: 'Accounts', params: {throttled: true}}
      callback(null, 'the results')

  afterEach ->
    delete DashboardController.app
    @fetchStub.restore()

  describe '#show', ->
    it 'fetches the password change request', (done)->
      params = {}
      callback = (err, result)->
        expect(err).to.equal(null)
        expect(result).to.equal('the results')
        done()
      test('show', params, callback)
