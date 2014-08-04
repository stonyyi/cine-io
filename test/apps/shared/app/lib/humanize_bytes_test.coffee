humanizeBytes = Cine.lib('humanize_bytes')

describe 'humanizeBytes', ->

  it 'humanizes bytes', ->
    expect(humanizeBytes(12355)).to.equal("12 KB")
    expect(humanizeBytes(12353735)).to.equal("11.78 MB")
    expect(humanizeBytes(1238888855)).to.equal("1.15 GB")
    expect(humanizeBytes(1238888855)).to.equal("1.15 GB")
    expect(humanizeBytes(7373737373636)).to.equal("6.71 TB")

  describe '#formatString', ->
    it 'returns the correct format', ->
      expect(humanizeBytes.formatString(12355)).to.equal("KB")
      expect(humanizeBytes.formatString(12353735)).to.equal("MB")
      expect(humanizeBytes.formatString(1238888855)).to.equal("GB")
      expect(humanizeBytes.formatString(1238888855)).to.equal("GB")
      expect(humanizeBytes.formatString(7373737373636)).to.equal("TB")
