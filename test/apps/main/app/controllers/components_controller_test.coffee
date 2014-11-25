ComponentsController = Cine.controller 'components'
ControllerTester = Cine.require('test/helpers/test_controller_action')
AssertTitleAndDescription = Cine.require('test/helpers/assert_title_and_description')
test = ControllerTester(ComponentsController)

describe 'ComponentsController', ->

  describe '#show', ->

    describe 'in test', ->

      beforeEach ->
        ComponentsController.app = mainApp

      AssertTitleAndDescription ComponentsController

      afterEach ->
        delete ComponentsController.app

      it 'fails when not development', (done)->
        params = {}
        callback = (err, viewOptions)->
          expect(err.status).to.equal(404)
          done()
        test('show', params, callback)

    describe 'in development', ->
      beforeEach ->
        app = newApp()
        app.attributes.env = 'development'
        ComponentsController.app = app

      AssertTitleAndDescription ComponentsController

      it 'completes when logged in', (done)->
        params = {id: 'abc'}
        callback = (err, viewOptions)->
          expect(err).to.be.null
          expect(viewOptions).to.deep.equal(component: 'abc')
          done()
        test('show', params, callback)
