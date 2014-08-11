module.exports = class BandwidthCalculator
  constructor: ->
    @numberOfViewers = 0
    @videoQuality = 0
    @videoLength = 0
    @simultaneousBroadcasts = 0
  calculate: ->
