User = Cine.server_model('user')
_ = require('underscore')

module.exports = (params, callback)->
  query = {}
  if params.sessionUserId
    query._id = params.sessionUserId
  if params.userToken
    query.masterKey = params.userToken
  return callback('not logged in or userToken not supplied', null, status: 401) if _.isEmpty(query)
  User.findOne query, (err, user)->
    return callback(err, null, status: 401) if err
    return callback('user not found', null, status: 404) if !user
    callback(null, user)
