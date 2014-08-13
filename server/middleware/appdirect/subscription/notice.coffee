# http://info.appdirect.com/developers/docs/api_integration/subscription_management/subscription_notice_event
Account = Cine.server_model('account')
verifySourceOauth = Cine.server_lib('appdirect/verify_source_oauth')
makeAppdirectRequest = Cine.server_lib('appdirect/make_appdirect_request')
sendAppdirectResponse = Cine.server_lib('appdirect/send_appdirect_response')
deleteAccount = Cine.server_lib('delete_account')
cancelAppdirectAccount = Cine.middleware('appdirect/subscription/cancel')

# POSSIBLE EVENT TYPES: DEACTIVATED REACTIVATED CLOSED UPCOMING_INVOICE

getAccount = (accountId, isDeleted, callback)->
  # testing integration stuff
  if accountId == 'dummy-account'
    # we still want to run the query just to make sure the account exists...
    query = "billingEmail": "test-email+creator@appdirect.com"
  else
    query = _id: accountId
  query.deletedAt = {$exists: isDeleted}
  # console.log("LOOKING UP USER", query)
  Account.findOne query, callback

deactivateAccount = (accountId, res)->
  getAccount accountId, false, (err, account)->
    return sendAppdirectResponse(res, 'unknownError') if err
    return sendAppdirectResponse(res, 'accountDoesNotExist', accountId) if !account
    account.deletedAt = new Date
    account.save (err, account)->
      return sendAppdirectResponse(res, 'unknownError') if err
      sendAppdirectResponse(res, 'accountDeactivated', account)

reactivateAccount = (accountId, res)->
  getAccount accountId, true, (err, account)->
    return sendAppdirectResponse(res, 'unknownError') if err
    return sendAppdirectResponse(res, 'accountDoesNotExist', accountId) if !account
    account.deletedAt = undefined
    account.save (err, account)->
      return sendAppdirectResponse(res, 'unknownError') if err
      sendAppdirectResponse(res, 'accountReactivated', account)

noticeSubscription = (req, res)->
  return sendAppdirectResponse(res, 'unauthorized', "Invalid oauth signature.") unless verifySourceOauth(req)

  makeAppdirectRequest req.param('url'), (err, statusCode, jsonResponse)->
    return sendAppdirectResponse(res, 'invalidResponse') if statusCode != 200
    # console.log("GOT PAYLOAD", jsonResponse)
    notice = jsonResponse.payload.notice.type
    accountId = jsonResponse.payload.account.accountIdentifier
    switch notice
      when 'CLOSED'
        return cancelAppdirectAccount.doCancel(accountId, res)
      when 'DEACTIVATED'
        return deactivateAccount(accountId, res)
      when 'REACTIVATED'
        return reactivateAccount(accountId, res)
      when 'UPCOMING_INVOICE'
        throw new Error("NOT IMPLEMENTED")
      else
        return sendAppdirectResponse(res, 'configurationError')

module.exports = (app)->
  app.get '/appdirect/notice', noticeSubscription
