ReactView = Cine.view('react')

describe 'ReactView', ->

  it 'is the arch', ->
    expect(ReactView).to.equal(Cine.arch('shared_base_view'))
