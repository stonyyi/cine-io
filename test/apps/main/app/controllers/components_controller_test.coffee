Components = Cine.controller 'components'
ControllerTester = Cine.require('test/helpers/test_controller_action')
test = ControllerTester(Components)

describe 'Components', ->
  beforeEach ->
    Components.app = mainApp

  afterEach ->
    delete Components.app

  describe '#show', ->
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
        Components.app = app

      it 'completes when logged in', (done)->
        params = {id: 'abc'}
        callback = (err, viewOptions)->
          expect(err).to.be.null
          expect(viewOptions).to.deep.equal(component: 'abc')
          done()
        test('show', params, callback)
