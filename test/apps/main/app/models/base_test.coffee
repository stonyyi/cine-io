Base = Cine.model('base')
RendrBase = require 'rendr/shared/base/model'

class Other extends Base
  afterInitialize: ->
    @that = 'hey'

describe 'Base', ->
  it 'extends RendrBase', ->
    b = new Base
    expect(b).to.be.an.instanceOf(Base)
    expect(b).to.be.an.instanceOf(RendrBase)

  describe 'afterInitialize', ->
    it 'gets called after initialize', ->
      o = new Other
      expect(o.that).to.equal('hey')

  describe 'api', ->
    it 'returns the app api', ->
      b = new Base({}, app: mainApp)
      expect(b.api()).to.equal(1)

  describe 'store', ->
    beforeEach ->
      @spy = sinon.spy RendrBase.prototype, 'store'
    afterEach ->
      @spy.restore()
    it 'will not store if there is no id', ->
      o = new Other({}, app: mainApp)
      o.store()
      expect(@spy.called).to.be.false

    it 'will call store if there is an id', ->
      o = new Other({id: 1}, app: mainApp)
      o.store()
      expect(@spy.called).to.be.true
