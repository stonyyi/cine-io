AppView = Cine.view('app_view',null, 'admin')

describe 'AppView', ->

  it 'is the arch', ->
    expect(AppView).to.equal(Cine.arch('shared_app_view'))
