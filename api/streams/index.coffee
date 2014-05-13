async = require('async')
EdgecastStream = Cine.model('edgecast_stream')
Show = Cine.api('streams/show')

module.exports = (callback)->
  scope = EdgecastStream.find()
    .where('_project').equals(@project._id)
    .exists('deletedAt', false)
    .sort(createdAt: -1)
  scope.exec (err, streams)->
    return callback(err, null, status: err.status || 400) if err
    async.map streams, Show.toJSON, (err, response)->
      callback(err, response)

module.exports.project = true
