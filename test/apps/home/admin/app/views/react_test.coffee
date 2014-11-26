ReactView = Cine.view('react', null, 'admin')

describe 'ReactView', ->

  it 'is the arch', ->
    expect(ReactView).to.equal(Cine.arch('shared_base_view'))
