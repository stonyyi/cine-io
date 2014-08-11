BandwidthCalculator = Cine.lib('bandwidth_calculator')

describe 'BandwidthCalculator', ->
  describe 'new'
    it 'has defaults', ->
      b = new BandwidthCalculator
      expect(b.numberOfViewers).to.equal(0)
      expect(b.videoQuality).to.equal(0)
      expect(b.videoLength).to.equal(0)
      expect(b.simultaneousBroadcasts).to.equal(0)

  describe '#calculate', ->
    beforeEach ->
      @calc = new BandwidthCalculator

    it 'is implemented'
