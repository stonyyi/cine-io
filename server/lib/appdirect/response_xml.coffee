builder = require('xmlbuilder')
_ = require('underscore')

# valid error codes:
# http://info.appdirect.com/developers/docs/event_references/api_error_codes/
# USER_ALREADY_EXISTS, USER_NOT_FOUND, ACCOUNT_NOT_FOUND, MAX_USERS_REACHED, UNAUTHORIZED, OPERATION_CANCELED, CONFIGURATION_ERROR, INVALID_RESPONSE, UNKNOWN_ERROR


# <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
# <result>
#     <success>false</success>
#     <errorCode>ACCOUNT_NOT_FOUND</errorCode>
#     <message>The account TEST123 could not be found.</message>
# </result>
responseXML = (options)->
  xml = builder.create('result')
  # add additional decs
  xml.dec('1.0', 'UTF-8', true)
  xml.ele(options)
  xml.end(pretty: true)

responseXML.unauthorized = (message)->
  responseXML(success: false, errorCode: 'UNAUTHORIZED', message: message)

responseXML.configurationError = (message="Our server is not configured to handle this request.")->
  responseXML(success: false, errorCode: 'CONFIGURATION_ERROR', message: message)

responseXML.unknownError = (message="An unknown error occured")->
  responseXML(success: false, errorCode: 'UNKNOWN_ERROR', message: message)

responseXML.invalidResponse = (email)->
  responseXML(success: false, errorCode: 'INVALID_RESPONSE', message: "Could not fetch event details.")

responseXML.userExists = (email)->
  responseXML(success: false, errorCode: 'USER_ALREADY_EXISTS', message: "The account for #{email} already exists.")

responseXML.userDoesNotExist = (email)->
  responseXML(success: false, errorCode: 'USER_NOT_FOUND', message: "The account for #{email} does not exist.")

responseXML.accountDoesNotExist = (userId)->
  responseXML(success: false, errorCode: 'ACCOUNT_NOT_FOUND', message: "The account #{userId} does not exist.")

responseXML.accountCreated = (account)->
  responseXML(success: true, accountIdentifier: account._id.toString(), message: "The account for #{account.billingEmail} was created.")

responseXML.planChanged = (account)->
  responseXML(success: true, accountIdentifier: account._id.toString(), message: "The account for #{account.billingEmail} was changed to #{account.plans[0]}.")

responseXML.accountCanceled = (account)->
  responseXML(success: true, accountIdentifier: account._id.toString(), message: "The account for #{account.billingEmail} was canceled.")

responseXML.accountDeactivated = (account)->
  responseXML(success: true, accountIdentifier: account._id.toString(), message: "The account for #{account.billingEmail} was deactivated.")

responseXML.accountReactivated = (account)->
  responseXML(success: true, accountIdentifier: account._id.toString(), message: "The account for #{account.billingEmail} was reactivated.")

responseXML.addonAdded = (account, plan)->
  responseXML(success: true, accountIdentifier: account._id.toString(), id: plan, message: "The addon #{plan} was added to the account for #{account.billingEmail}.")

responseXML.addonRemoved = (account, plan)->
  responseXML(success: true, accountIdentifier: account._id.toString(), message: "The addon #{plan} was removed from the account for #{account.billingEmail}.")

responseXML.addonBind = (account, project, plan)->
  responseXML
    success: true
    accountIdentifier: account._id.toString()
    metadata: [
      {entry: {key: 'secretKey', value: project.secretKey}}
      {entry: {key: 'publicKey', value: project.publicKey}}
    ]
    message: "The addon #{plan} was bound with the account for #{account.billingEmail}."

responseXML.addonUnBind = (account, plan)->
  responseXML(success: true, accountIdentifier: account._id.toString(), message: "The addon #{plan} was unbound from the account for #{account.billingEmail}.")

module.exports = responseXML
