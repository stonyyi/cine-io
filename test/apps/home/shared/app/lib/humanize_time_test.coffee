humanizeTime = Cine.lib('humanize_time')

describe 'humanizeTime', ->

  it 'humanizes', ->
    expect(humanizeTime(0)).equal('0 seconds')
    expect(humanizeTime(1)).to.equal("1 second")
    expect(humanizeTime(1 * 1000)).to.equal("1 second")
    expect(humanizeTime(65 * 1000)).to.equal("1 minute and 5 seconds")
    expect(humanizeTime(465 * 1000)).to.equal("7 minutes and 45 seconds")
    expect(humanizeTime(5658 * 1000)).to.equal("1 hour, 34 minutes, and 18 seconds")
    expect(humanizeTime(22658 * 1000)).to.equal("6 hours, 17 minutes, and 38 seconds")
    expect(humanizeTime(1022658 * 1000)).to.equal("11 days, 20 hours, 4 minutes, and 18 seconds")
    expect(humanizeTime(101022658 * 1000)).to.equal("1169 days, 5 hours, 50 minutes, and 58 seconds")

  describe 'toObject', ->
    it 'humanizes', ->
      expect(humanizeTime.toObject(0)).to.be.empty
      expect(humanizeTime.toObject(1)).to.deep.equal(seconds: 1)
      expect(humanizeTime.toObject(1 * 1000)).to.deep.equal(seconds: 1)
      expect(humanizeTime.toObject(65 * 1000)).to.deep.equal(minutes: 1, seconds: 5)
      expect(humanizeTime.toObject(465 * 1000)).to.deep.equal(minutes: 7, seconds: 45)
      expect(humanizeTime.toObject(5658 * 1000)).to.deep.equal(hours: 1, minutes: 34, seconds: 18)
      expect(humanizeTime.toObject(22658 * 1000)).to.deep.equal(hours: 6, minutes: 17, seconds: 38)
      expect(humanizeTime.toObject(1022658 * 1000)).to.deep.equal(days: 11, hours: 20, minutes: 4, seconds: 18)
      expect(humanizeTime.toObject(101022658 * 1000)).to.deep.equal(days: 1169, hours: 5, minutes: 50, seconds: 58)
