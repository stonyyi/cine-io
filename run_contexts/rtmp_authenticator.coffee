_ = require('underscore')
Base = require('./base')
Cine.config('connect_to_mongo')
runMe = !module.parent

EdgecastStream = Cine.server_model('edgecast_stream')

app = exports.app = Base.app()

app.get '/', (req, res)->
  res.send("I am the rtmp_authenticator")

# HTTP request receives a number of arguments. POST method is used with
# application/x-www-form-urlencoded MIME type. The following arguments are
# passed to caller:
#
# call=connect
# addr - client IP address
# app - application name
# flashVer - client flash version
# swfUrl - client swf url
# tcUrl - tcUrl
# pageUrl - client page url

app.post '/', (req, res)->
  console.log("got request", req.body)

  return res.status(404).send("no stream name provided") unless req.body.name

  query =
    streamName: req.body.name
  EdgecastStream.findOne query, (err, stream)->
    return res.status(400).send(err) if err
    return res.status(404).send("invalid stream: #{req.body.name}") unless stream
    return res.status(401).send("unauthorized") unless _.has(req.body, stream.streamKey)
    res.send("OK")

Base.listen app, 8183 if runMe
