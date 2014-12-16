# http://info.appdirect.com/developers/docs/api_integration/subscription_management/addon-management
# http://info.appdirect.com/developers/docs/cloud-foundry/cf-cli-commands
Account = Cine.server_model('account')
verifySourceOauth = Cine.server_lib('appdirect/verify_source_oauth')
makeAppdirectRequest = Cine.server_lib('appdirect/make_appdirect_request')
sendAppdirectResponse = Cine.server_lib('appdirect/send_appdirect_response')
_ = require('underscore')
AccountThrottler = Cine.server_lib('account_throttler')

getAccount = (accountId, callback)->
  # testing integration stuff
  if accountId == 'dummy-account'
    # we still want to run the query just to make sure the account exists...
    query = "billingEmail": "test-email+creator@appdirect.com"
  else
    query = _id: accountId
  query.deletedAt = {$exists: false}
  Account.findOne query, callback

addPlanToAccount = (accountId, plan, res)->
  getAccount accountId, (err, account)->
    return sendAppdirectResponse(res, 'unknownError') if err
    return sendAppdirectResponse(res, 'accountDoesNotExist', accountId) if !account
    account.productPlans.broadcast.push plan
    AccountThrottler.unthrottle account, (err, account)->
      return sendAppdirectResponse(res, 'unknownError') if err
      sendAppdirectResponse(res, 'addonAdded', account, plan)

removePlanFromPlans = (account, plan)->
  # cannot use _.without because it removes ALL instances of that plan.
  indexOfPlan = _.indexOf(account.productPlans.broadcast, plan)
  account.productPlans.broadcast.splice(indexOfPlan, 1)

removePlanFromAccount = (accountId, plan, res)->
  getAccount accountId, (err, account)->
    return sendAppdirectResponse(res, 'unknownError') if err
    return sendAppdirectResponse(res, 'accountDoesNotExist', accountId) if !account
    removePlanFromPlans(account, plan)
    account.save (err, account)->
      return sendAppdirectResponse(res, 'unknownError') if err
      sendAppdirectResponse(res, 'addonRemoved', account, plan)

returnProjectForAccount = (accountId, plan, res)->
  getAccount accountId, (err, account)->
    return sendAppdirectResponse(res, 'unknownError') if err
    return sendAppdirectResponse(res, 'accountDoesNotExist', accountId) if !account
    account.projects (err, projects)->
      return sendAppdirectResponse(res, 'unknownError') if err
      project = projects[0]
      return sendAppdirectResponse(res, 'unknownError') unless project
      sendAppdirectResponse(res, 'addonBind', account, project, plan)

unbindAccount = (accountId, plan, res)->
  getAccount accountId, (err, account)->
    return sendAppdirectResponse(res, 'unknownError') if err
    return sendAppdirectResponse(res, 'accountDoesNotExist', accountId) if !account
    sendAppdirectResponse(res, 'addonUnBind', account, plan)

handleAddons = (req, res)->
  return sendAppdirectResponse(res, 'unauthorized', "Invalid oauth signature.") unless verifySourceOauth(req)

  makeAppdirectRequest req.param('url'), (err, statusCode, jsonResponse)->
    # console.log("GOT APPDIRECT RESPONSE", err, statusCode, jsonResponse)
    return sendAppdirectResponse(res, 'invalidResponse') if statusCode != 200
    type = jsonResponse.type
    accountId = jsonResponse.payload.account.accountIdentifier
    switch type
      when 'ADDON_ORDER'
        addonName = jsonResponse.payload.order.addonOfferingCode
        return addPlanToAccount(accountId, addonName, res)
      when 'ADDON_CANCEL'
        addonName = jsonResponse.payload.addonInstance.id
        return removePlanFromAccount(accountId, addonName, res)
      when 'ADDON_BIND'
        addonName = jsonResponse.payload.addonInstance.id
        return returnProjectForAccount(accountId, addonName, res)
      when 'ADDON_UNBIND'
        addonName = jsonResponse.payload.addonInstance.id
        return unbindAccount(accountId, addonName, res)
      else
        return sendAppdirectResponse(res, 'configurationError')

module.exports = (app)->
  app.get '/appdirect/addons', handleAddons
