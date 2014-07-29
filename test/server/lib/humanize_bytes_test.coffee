humanizeBytes = Cine.server_lib('humanize_bytes')

describe 'humanizeBytes', ->

  it 'humanizes bytes', ->
    expect(humanizeBytes(12355)).to.equal("12 KB")
    expect(humanizeBytes(12353735)).to.equal("11.78 MB")
    expect(humanizeBytes(1238888855)).to.equal("1.15 GB")
