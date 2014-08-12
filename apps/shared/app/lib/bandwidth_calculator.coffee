module.exports = class BandwidthCalculator
  constructor: ->
    @numberOfViewers = 0 #in users
    @bitRate = 0 # in kbps
    @videoLength = 0 # in minutes
    @simultaneousBroadcasts = 1 #number
  calculate: ->
    viewingMinutes = @numberOfViewers * @videoLength
    viewingSeconds = viewingMinutes * 60
    bytesPerSecond = @bitRate / 8
    dataPerStream = viewingSeconds * bytesPerSecond
    dataPerStream * @simultaneousBroadcasts
