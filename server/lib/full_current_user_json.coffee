User = Cine.server_model('user')
Account = Cine.server_model('account')
_ = require('underscore')

toJsonProxy = (model)->
  model.toJSON()

module.exports = (user, callback)->
  userJSON = user.simpleCurrentUserJSON()
  return callback(null, userJSON) if _.isEmpty(userJSON._accounts)

  Account.find _id: {$in: userJSON._accounts}, (err, accounts)->
    return callback(err, userJSON) if err
    userJSON.accounts = _.map(accounts, toJsonProxy)
    callback(null, userJSON)
