# http://info.appdirect.com/developers/docs/api_integration/subscription_management/subscription_order_event
verifySourceOauth = Cine.server_lib('appdirect/verify_source_oauth')
makeAppdirectRequest = Cine.server_lib('appdirect/make_appdirect_request')
sendAppdirectResponse = Cine.server_lib('appdirect/send_appdirect_response')
createNewAccount = Cine.server_lib('create_new_account')
mailer = Cine.server_lib('mailer')

accountAttributesFromJson = (jsonResponse)->
  payload = jsonResponse.payload
  attributes =
    name: payload.company.name
    appdirectData: jsonResponse
    billingProvider: 'appdirect'
  return attributes

userAttributesFromJson = (jsonResponse)->
  userAttributes = jsonResponse.creator
  attributes =
    email: userAttributes.email
    name: "#{userAttributes.firstName} #{userAttributes.lastName}"
    appdirectUUID: userAttributes.uuid
    appdirectData: userAttributes
  return attributes

createSubscription = (req, res)->
  return sendAppdirectResponse(res, 'unauthorized', "Invalid oauth signature.") unless verifySourceOauth(req)

  makeAppdirectRequest req.param('url'), (err, statusCode, jsonResponse)->
    return sendAppdirectResponse(res, 'invalidResponse') if statusCode != 200
    accountAttributes = accountAttributesFromJson(jsonResponse)
    userAttributes = userAttributesFromJson(jsonResponse)
    createNewAccount accountAttributes, userAttributes, (err, result)->
      console.log("DONE", err, result)
      return sendAppdirectResponse(res, 'unknownError') if err
      mailer.welcomeEmail(result.user)
      mailer.admin.newUser(result.account, result.user, 'appdirect')
      sendAppdirectResponse(res, 'accountCreated', result.account)

module.exports = (app)->
  app.get '/appdirect/create', createSubscription
