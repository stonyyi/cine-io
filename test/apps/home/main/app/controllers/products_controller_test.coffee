ProductsController = Cine.controller 'products'
ControllerTester = Cine.require('test/helpers/test_controller_action')
AssertTitleAndDescription = Cine.require('test/helpers/assert_title_and_description')
test = ControllerTester(ProductsController)

describe 'ProductsController', ->
  beforeEach ->
    ProductsController.app = mainApp

  AssertTitleAndDescription ProductsController, ProductsController.titlesAndDescriptions.broadcast

  afterEach ->
    delete ProductsController.app

  describe '#show', ->
    describe 'main usage', ->
      beforeEach ->
        ProductsController.app = mainApp

      afterEach ->
        delete ProductsController.app

      it 'returns a document', (done)->
        params = {id: 'broadcast'}
        callback = (err, result)->
          expect(err).to.equal(null)
          expect(result).to.deep.equal(product: 'broadcast')
          done()
        test('show', params, callback)
