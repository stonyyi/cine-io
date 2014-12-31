pluralize = Cine.lib('pluralize')

describe 'pluralize', ->

  it 'pluralizes', ->
    expect(pluralize(0, 'thing')).to.equal("things")
    expect(pluralize(1, 'thing')).to.equal("thing")
    expect(pluralize(2, 'thing')).to.equal("things")
