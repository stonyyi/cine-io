Base = Cine.collection('base')
RendrBase = require 'rendr/shared/base/collection'

describe 'Base', ->
  it 'extends RendrBase', ->
    b = new Base
    expect(b).to.be.an.instanceOf(Base)
    expect(b).to.be.an.instanceOf(RendrBase)

  describe 'api', ->
    it 'returns the app api', ->
      b = new Base({}, app: mainApp)
      expect(b.api()).to.equal(1)
