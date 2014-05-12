_ = require('underscore')
EdgecastStream = Cine.model('edgecast_stream')

toJsonProxy = (model)->
  model.toJSON()

module.exports = (params, callback)->
  scope = EdgecastStream.find()
  scope = scope.exists('deletedAt', false)
  scope = scope.sort(createdAt: -1)
  scope.exec (err, streams)->
    return callback(err, null, status: err.status || 400) if err
    response = _.map streams, toJsonProxy
    callback(null, response)
