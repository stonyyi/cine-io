Base = require('../base')
runMe = !module.parent

async = require('async')
request = require('request')

Debug = require('debug')
Debug.enable('cine:*')
debug = Debug("cine:rtmp_stats:index")

parseNginxRtmpXml = Cine.app('rtmp_stats/lib/parse_nginx_rtmp_xml')

app = exports.app = Base.app("rtmp stats")

app.get '/', (req, res)->
  res.send('cine.io rtmp stats')

RTMP_REPLICATOR = process.env.RTMP_REPLICATOR_SERVER || 'rtmp-replicator'
RTMP_STYLIST = process.env.RTMP_STYLIST_SERVER || 'rtmp-stylist'

getRTMPServerStats = (server, callback)->
  request.get "http://#{server}/stats", (err, response, body)->
    return callback(err) if err
    return callback(body) if response.statusCode != 200

    parseNginxRtmpXml body, (err, stats)->
      return callback(err) if err
      callback(null, stats)

getAllStats = (callback)->
  asyncCalls =
    replicator: (cb)->
      getRTMPServerStats RTMP_REPLICATOR, cb
    stylist: (cb)->
      getRTMPServerStats RTMP_STYLIST, cb

  async.parallel asyncCalls, callback

app.get '/stats', (req, res)->
  getAllStats (err, response)->
    return res.status(400).send(err) if err
    res.send(response)

Base.listen app if runMe
