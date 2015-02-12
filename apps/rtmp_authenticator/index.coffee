_ = require('underscore')
Base = require('../base')
Cine.config('connect_to_mongo')
runMe = !module.parent

EdgecastStream = Cine.server_model('edgecast_stream')
Project = Cine.server_model('project')

app = exports.app = Base.app("rtmp authenticator")

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
  streamName = req.body.name

  # if '0ffa=true' is passed, we're coming from the rtmp-stylist to the rtmp-
  # replicator and want to avoid double-authentication
  return res.send("OK") if req.body["0ffa"] == "true"

  return res.status(404).send("no stream name provided") unless streamName
  query =
    streamName: streamName
  EdgecastStream.findOne query, (err, stream)->
    return res.status(400).send(err) if err
    return res.status(404).send("invalid stream: #{streamName}") unless stream
    return res.status(401).send("unauthorized") unless _.has(req.body, stream.streamKey)
    Project.findById stream._project, (err, project)->
      return res.status(400).send(err) if err
      return res.status(404).send("could not find project: #{stream._project}") unless project
      return res.status(402).send("project is disabled") if project.throttledAt
      res.send("OK")

Base.listen app if runMe
