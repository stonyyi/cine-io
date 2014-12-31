humanizeNumber = Cine.lib('humanize_number')

describe 'humanizeNumber', ->

  it 'humanizes bytes', ->
    expect(humanizeNumber(1)).to.equal("1")
    expect(humanizeNumber(155)).to.equal("155")
    expect(humanizeNumber(12355)).to.equal("12,355")
    expect(humanizeNumber(12.355)).to.equal("12")

    expect(humanizeNumber(12.355, 1)).to.equal("12.4")
    expect(humanizeNumber(12.355, 1, ',', ':')).to.equal("12:4")
    expect(humanizeNumber(1332.355, 2, '{', ':')).to.equal("1{332:36")
