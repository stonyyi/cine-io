async = require('async')
EdgecastStream = Cine.server_model('edgecast_stream')
Show = Cine.api('streams/show')
getProject = Cine.server_lib('get_project')

module.exports = (params, callback)->
  getProject params, (err, project, status)->
    return callback(err, project, status) if err
    scope = EdgecastStream.find()
      .where('_project').equals(project._id)
      .exists('deletedAt', false)
      .sort(createdAt: -1)
    scope.exec (err, streams)->
      return callback(err, null, status: err.status || 400) if err
      async.map streams, Show.toJSON, (err, response)->
        callback(err, response)
