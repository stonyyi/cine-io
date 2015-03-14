# takes in nginx stats and returns
# input:
#   total: 2
# output:
#   total: 3
#   streams:
#     stream-name-1: 2
#     stream-name-2: 1
{parseString} = require 'xml2js'
_ = require('underscore')

parseStream = (stream)->
  publishing = false
  players = 0
  name = stream.name[0]
  bitrate = null
  _.each stream.client, (client)->
    # you're either publishing or a player
    if client.publishing?
      publishing = true
      bitrate = Number(stream.bw_in[0])
    else
      players += 1
  return publishing: publishing, players: players, name: name, bitrate: bitrate

accumStreamStats = (accum, stream)->
  stats = parseStream(stream)
  if stats.publishing
    accum.input.total += 1
    accum.input.streams[stats.name] = bitrate: stats.bitrate
  accum.output.total += stats.players
  accum.output.streams[stats.name] = stats.players
  accum

module.exports = (rtmp_stats, callback)->
  parseString rtmp_stats, (err, result) ->
    return callback(err) if err

    # this assumes there's a single endpoint called /live
    streams = result.rtmp.server[0].application[0].live[0].stream

    initialAccum =
      input:
        total: 0
        streams: {}
      output:
        total: 0
        streams: {}

    response = _.inject streams, accumStreamStats, initialAccum
    callback null, response
