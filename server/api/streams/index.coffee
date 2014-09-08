async = require('async')
EdgecastStream = Cine.server_model('edgecast_stream')
Show = Cine.api('streams/show')
getProject = Cine.server_lib('get_project')

module.exports = (params, callback)->
  getProject params, requires: 'secret', userOverride: true, (err, project, options)->
    return callback(err, project, options) if err
    scope = EdgecastStream.find()
      .where('_project').equals(project._id)
      .exists('deletedAt', false)
      .sort(createdAt: -1)
    if params.name
      scope = scope.where('name').equals(params.name)
    scope.exec (err, streams)->
      return callback(err, null, status: err.status || 400) if err
      streamOptions = {}
      Show.addEdgecastServerToStreamOptions(streamOptions, params) if options.secure

      fullJsonFunction = (stream, callback)->
        Show.fullJSON(stream, streamOptions, callback)

      jsonFunction = if options.secure then fullJsonFunction else Show.playJSON
      async.map streams, jsonFunction, (err, response)->
        callback(err, response)
