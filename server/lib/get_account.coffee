Account = Cine.server_model('account')
_ = require('underscore')

module.exports = (params, callback)->
  query = {}
  if params.masterKey
    query.masterKey = params.masterKey
  return callback('masterKey not supplied', null, status: 401) if _.isEmpty(query)
  Account.findOne query, (err, account)->
    return callback(err, null, status: 401) if err
    return callback('account not found', null, status: 404) if !account
    callback(null, account)
