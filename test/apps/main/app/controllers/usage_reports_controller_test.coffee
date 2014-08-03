UsageReportsController = Cine.controller 'usage_reports'
ControllerTester = Cine.require('test/helpers/test_controller_action')
test = ControllerTester(UsageReportsController)

describe 'UsageReportsController', ->
  beforeEach ->
    UsageReportsController.app = mainApp
    @fetchStub = sinon.stub mainApp, "fetch", (spec, callback)->
      expect(spec).to.deep.equal(model: {model: 'UsageReport', params: {masterKey: 'the master key'}})
      callback(null, 'the usage report')

  afterEach ->
    delete UsageReportsController.app
    @fetchStub.restore()

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

      it 'fetches the usage report', (done)->
        params = {}
        callback = (err, result)->
          expect(err).to.equal(null)
          expect(result).to.equal('the usage report')
          done()
        test('show', params, callback)
