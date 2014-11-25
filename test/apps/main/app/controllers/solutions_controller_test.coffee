SolutionsController = Cine.controller 'solutions'
ControllerTester = Cine.require('test/helpers/test_controller_action')
test = ControllerTester(SolutionsController)

describe 'SolutionsController', ->
  describe '#show', ->
    describe 'main usage', ->
      beforeEach ->
        SolutionsController.app = mainApp
        @fetchStub = sinon.stub mainApp, "fetch", (spec, callback)->
          expect(spec).to.deep.equal(model: {model: 'StaticDocument', params: {id: 'solutions/ios'}})
          callback(null, 'some document')

      afterEach ->
        delete SolutionsController.app
        @fetchStub.restore()

      it 'returns a document', (done)->
        params = {id: 'ios'}
        callback = (err, result)->
          expect(err).to.equal(null)
          expect(result).to.equal('some document')
          done()
        test('show', params, callback)
