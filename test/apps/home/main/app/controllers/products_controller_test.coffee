ProductsController = Cine.controller 'products'
ControllerTester = Cine.require('test/helpers/test_controller_action')
AssertTitleAndDescription = Cine.require('test/helpers/assert_title_and_description')
test = ControllerTester(ProductsController)

describe 'ProductsController', ->
  beforeEach ->
    ProductsController.app = mainApp


  afterEach ->
    delete ProductsController.app

  describe '#show', ->
    it 'returns a 404 for an invalid product', (done)->
      params = {id: 'NOT_A_PRODUCT'}
      callback = (err, result)->
        expect(err).to.deep.equal(status: 404)
        expect(result).to.be.undefined
        done()
      test('show', params, callback)

    describe 'main usage', ->
      AssertTitleAndDescription ProductsController, ProductsController.titlesAndDescriptions.broadcast

      it 'returns a product', (done)->
        params = {id: 'broadcast'}
        callback = (err, result)->
          expect(err).to.equal(null)
          expect(result).to.deep.equal(product: 'broadcast')
          done()
        test('show', params, callback)
