humanizeBytes = Cine.lib('humanize_bytes')

describe 'humanizeBytes', ->

  it 'humanizes bytes', ->
    expect(humanizeBytes(1)).to.equal("1 byte")
    expect(humanizeBytes(155)).to.equal("155 bytes")
    expect(humanizeBytes(12355)).to.equal("12 KiB")
    expect(humanizeBytes(12353735)).to.equal("11.78 MiB")
    expect(humanizeBytes(1238888855)).to.equal("1.15 GiB")
    expect(humanizeBytes(1238888855)).to.equal("1.15 GiB")
    expect(humanizeBytes(7373737373636)).to.equal("6.71 TiB")
    expect(humanizeBytes(7373737373636000)).to.equal("6,706.38 TiB")

  describe '#formatString', ->
    it 'returns the correct format', ->
      expect(humanizeBytes.formatString(12355)).to.equal("KiB")
      expect(humanizeBytes.formatString(12353735)).to.equal("MiB")
      expect(humanizeBytes.formatString(1238888855)).to.equal("GiB")
      expect(humanizeBytes.formatString(1238888855)).to.equal("GiB")
      expect(humanizeBytes.formatString(7373737373636)).to.equal("TiB")
