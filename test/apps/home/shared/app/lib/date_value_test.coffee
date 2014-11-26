Base = Cine.model('base')

class FakeModel extends Base
  @include Cine.lib('date_value')
  hello: ->
    @_dateValue('hello')

describe 'date_value', ->
  it 'transforms the value into a date', ->
    d = new Date()
    model = new FakeModel(hello: d.toISOString())
    expect(model.hello()).to.be.instanceOf(Date)
    expect(model.hello().toJSON()).to.equal(d.toJSON())

  it 'returns null if there is no date', ->
    d = new Date()
    model = new FakeModel()
    expect(model.hello()).to.be.null

  it 'returns null if the date is blank', ->
    d = new Date()
    model = new FakeModel(hello: '')
    expect(model.hello()).to.be.null
