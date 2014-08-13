# http://info.appdirect.com/developers/docs/api_integration/subscription_management/subscription_cancel_event
Account = Cine.server_model('account')
verifySourceOauth = Cine.server_lib('appdirect/verify_source_oauth')
makeAppdirectRequest = Cine.server_lib('appdirect/make_appdirect_request')
sendAppdirectResponse = Cine.server_lib('appdirect/send_appdirect_response')
deleteAccount = Cine.server_lib('delete_account')

doCancel = (accountId, res)->
  # testing integration stuff
  if accountId == 'dummy-account'
    # we still want to run the query just to make sure the user exists...
    query = "billingEmail": "test-email+creator@appdirect.com"
  else
    query = _id: accountId

  query.deletedAt = {$exists: false}
  # console.log("LOOKING UP USER", query)
  Account.findOne query, (err, user)->
    return sendAppdirectResponse(res, 'unknownError') if err
    return sendAppdirectResponse(res, 'accountDoesNotExist', accountId) if !user
    deleteAccount user, (err, results)->
      return sendAppdirectResponse(res, 'unknownError') if err
      sendAppdirectResponse(res, 'accountCanceled', user)

cancelSubscription = (req, res)->
  return sendAppdirectResponse(res, 'unauthorized', "Invalid oauth signature.") unless verifySourceOauth(req)

  makeAppdirectRequest req.param('url'), (err, statusCode, jsonResponse)->
    return sendAppdirectResponse(res, 'invalidResponse') if statusCode != 200
    # console.log("GOT PAYLOAD", jsonResponse)
    accountId = jsonResponse.payload.account.accountIdentifier
    doCancel(accountId, res)

module.exports = (app)->
  app.get '/appdirect/cancel', cancelSubscription

module.exports.doCancel = doCancel
