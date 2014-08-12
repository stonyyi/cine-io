module.exports = class BandwidthCalculator
  constructor: ->
    @numberOfViewers = 0 #in users
    @bitRate = 0 # in kbps
    @videoLength = 0 # in minutes
    @simultaneousBroadcasts = 1 #number

  calculate: ->
    numberOfStreamersPerStream = 1
    totalNumberOfStreamers = @simultaneousBroadcasts * numberOfStreamersPerStream
    numberOfViewersPlusTheStreamers = @numberOfViewers + totalNumberOfStreamers
    streamingUpOrDownMinutes = numberOfViewersPlusTheStreamers * @videoLength
    streamingUpOrDownSeconds = streamingUpOrDownMinutes * 60
    bytesPerSecond = (@bitRate * 1024) / 8
    dataPerStream = streamingUpOrDownSeconds * bytesPerSecond
    dataPerStream * @simultaneousBroadcasts
