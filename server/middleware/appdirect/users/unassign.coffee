# http://info.appdirect.com/developers/docs/api_integration/access_management/user_assignment_event
verifySourceOauth = Cine.server_lib('appdirect/verify_source_oauth')
makeAppdirectRequest = Cine.server_lib('appdirect/make_appdirect_request')
sendAppdirectResponse = Cine.server_lib('appdirect/send_appdirect_response')
Account = Cine.server_model('account')
User = Cine.server_model('user')
_ = require('underscore')

getAccount = (accountId, callback)->
  # testing integration stuff
  if accountId == 'dummy-account'
    # we still want to run the query just to make sure the account exists...
    query = "billingEmail": "test-email+creator@appdirect.com"
  else
    query = _id: accountId
  query.deletedAt = {$exists: false}
  Account.findOne query, callback


removeAccountFromAccounts = (accounts, accountId)->
  _.reject accounts, (assignedAccountId)->
    assignedAccountId.toString() == accountId.toString()

removeUserFromAccount = (account, userAttributesFromAppdirect, callback)->
  appdirectUUID = _.last(userAttributesFromAppdirect.openId.split('/'))
  User.findOne appdirectUUID: appdirectUUID, (err, user)->
    return callback(err) if err
    return callback() unless user

    user._accounts = removeAccountFromAccounts(user._accounts, account._id)
    user.save callback

unAssignUser = (req, res)->
  return sendAppdirectResponse(res, 'unauthorized', "Invalid oauth signature.") unless verifySourceOauth(req)

  makeAppdirectRequest req.param('url'), (err, statusCode, jsonResponse)->
    return sendAppdirectResponse(res, 'invalidResponse') if statusCode != 200
    accountId = jsonResponse.payload.account.accountIdentifier
    userAttributes = jsonResponse.payload.user
    getAccount accountId, (err, account)->
      return sendAppdirectResponse(res, 'unknownError') if err
      return sendAppdirectResponse(res, 'accountDoesNotExist', accountId) if !account
      removeUserFromAccount account, userAttributes, (err, user)->
        return sendAppdirectResponse(res, 'unknownError') if err
        return sendAppdirectResponse(res, 'userDoesNotExist', userAttributes.email) unless user
        sendAppdirectResponse(res, 'userUnAssigned')

module.exports = (app)->
  app.get '/appdirect/users/unassign', unAssignUser
