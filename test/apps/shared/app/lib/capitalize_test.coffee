capitalize = Cine.lib('capitalize')

describe 'capitalize', ->
  it 'capitalizes the first letter', ->
    expect(capitalize('steph')).to.equal("Steph")

  it 'accepts undefined', ->
    expect(capitalize()).to.be.undefined

  it 'accepts empty string', ->
    expect(capitalize('')).to.equal('')
