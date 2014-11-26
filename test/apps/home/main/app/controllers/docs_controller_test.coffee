DocsController = Cine.controller 'docs'
ControllerTester = Cine.require('test/helpers/test_controller_action')
AssertTitleAndDescription = Cine.require('test/helpers/assert_title_and_description')
test = ControllerTester(DocsController)

describe 'DocsController', ->
  describe '#show', ->
    beforeEach ->
      DocsController.app = mainApp
      @fetchStub = sinon.stub mainApp, "fetch", (spec, callback)->
        expect(spec).to.deep.equal(model: {model: 'StaticDocument', params: {id: 'docs/main'}})
        callback(null, 'some document')

    AssertTitleAndDescription DocsController

    afterEach ->
      delete DocsController.app
      @fetchStub.restore()

    it 'returns a document', (done)->
      params = {}
      callback = (err, result)->
        expect(err).to.equal(null)
        expect(result).to.equal('some document')
        done()
      test('show', params, callback)
