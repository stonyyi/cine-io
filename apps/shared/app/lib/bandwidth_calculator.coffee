module.exports = class BandwidthCalculator
  # https://support.google.com/youtube/answer/2853702?hl=en
  @bitRates:
    '240p': 400
    '360p': 750
    '480p': 1000
    '720p': 2500
    '1080p': 4500

  constructor: ->
    @numberOfViewers = 0 #in users
    @bitRate = 0 # in kbps
    @videoLength = 0 # in minutes
    @simultaneousBroadcasts = 1 #number

  setBitRate: (rateString)->
    rate = @constructor.bitRates[rateString]
    throw new Error("Unsupported bit rate: #{rateString}") unless rate
    @bitRate = rate

  calculate: ->
    viewingMinutes = @numberOfViewers * @videoLength
    viewingSeconds = viewingMinutes * 60
    bytesPerSecond = @bitRate / 8
    dataPerStream = viewingSeconds * bytesPerSecond
    dataPerStream * @simultaneousBroadcasts
