_ = require('underscore')
EdgecastStream = Cine.model('edgecast_stream')

toJsonProxy = (model)->
  model.toJSON()

module.exports = (organization, params, callback)->
  scope = EdgecastStream.find()
    .where('_organization').equals(organization._id)
    .exists('deletedAt', false)
    .sort(createdAt: -1)
  scope.exec (err, streams)->
    return callback(err, null, status: err.status || 400) if err
    response = _.map streams, toJsonProxy
    callback(null, response)
