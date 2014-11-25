LegalController = Cine.controller 'legal'
ControllerTester = Cine.require('test/helpers/test_controller_action')
AssertTitleAndDescription = Cine.require('test/helpers/assert_title_and_description')
test = ControllerTester(LegalController)

describe 'LegalController', ->
  describe '#show', ->
    describe 'main usage', ->
      beforeEach ->
        LegalController.app = mainApp
        @fetchStub = sinon.stub mainApp, "fetch", (spec, callback)->
          expect(spec).to.deep.equal(model: {model: 'StaticDocument', params: {id: 'legal/privacy-policy'}})
          callback(null, 'some document')

      AssertTitleAndDescription LegalController

      afterEach ->
        delete LegalController.app
        @fetchStub.restore()

      it 'returns a document', (done)->
        params = {id: 'privacy-policy'}
        callback = (err, result)->
          expect(err).to.equal(null)
          expect(result).to.equal('some document')
          done()
        test('show', params, callback)

    describe 'no id provided', ->
      beforeEach ->
        LegalController.app = mainApp
        @fetchStub = sinon.stub mainApp, "fetch", (spec, callback)->
          expect(spec).to.deep.equal(model: {model: 'StaticDocument', params: {id: 'legal/terms-of-service'}})
          callback(null, 'some document')

      afterEach ->
        delete LegalController.app
        @fetchStub.restore()

      it 'returns a document', (done)->
        params = {}
        callback = (err, result)->
          expect(err).to.equal(null)
          expect(result).to.equal('some document')
          done()
        test('show', params, callback)
