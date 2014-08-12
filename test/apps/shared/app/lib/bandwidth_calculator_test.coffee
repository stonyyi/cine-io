BandwidthCalculator = Cine.lib('bandwidth_calculator')

describe 'BandwidthCalculator', ->
  beforeEach ->
    @calc = new BandwidthCalculator

  describe 'new', ->
    it 'has defaults', ->
      expect(@calc.numberOfViewers).to.equal(0)
      expect(@calc.bitRate).to.equal(0)
      expect(@calc.videoLength).to.equal(0)
      expect(@calc.simultaneousBroadcasts).to.equal(1)

  describe '#calculate', ->
    it 'returns to total consumed bytes', ->
      @calc.numberOfViewers = 100
      @calc.videoLength = 30
      @calc.bitRate = 1500
      expect(@calc.calculate()).to.equal(33750000)

    it 'doubles with more broadcasts', ->
      @calc.numberOfViewers = 100
      @calc.videoLength = 30
      @calc.bitRate = 1500
      @calc.simultaneousBroadcasts = 2
      expect(@calc.calculate()).to.equal(67500000)

  describe '#setBitRate', ->
    it 'requires a valid format', ->
      fn = => @calc.setBitRate '100p'
      expect(fn).to.throw("Unsupported bit rate: 100p")

    it 'sets the bit rate from the recommendations', ->
      @calc.numberOfViewers = 100
      @calc.videoLength = 30
      @calc.setBitRate '720p'
      expect(@calc.calculate()).to.equal(56250000)
