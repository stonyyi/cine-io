_ = require('underscore')
_str = require 'underscore.string'
addStripeCardToAccount = Cine.server_lib("add_stripe_card_to_account")
deleteStripeCard = Cine.server_lib("delete_stripe_card")
getAccount = Cine.server_lib('get_account')
mailer = Cine.server_lib('mailer')
fullCurrentUserJson = Cine.server_lib('full_current_user_json')
TextMongooseErrorMessage = Cine.server_lib('text_mongoose_error_message')

module.exports = (params, callback)->
  getAccount params, (err, account, options)->
    return callback(err, account, options) if err

    if params.stripeToken
      return addStripeCardToAccount account, params.stripeToken, (err, account)->
        return callback(TextMongooseErrorMessage(err), null, status: 400) if err
        account.throttledAt = undefined
        account.save (err, account)->
          return callback(TextMongooseErrorMessage(err), null, status: 400) if err
          mailer.admin.cardAdded(account)
          fullCurrentUserJson.accountJson(account, callback)

    else if params.deleteCard
      return deleteStripeCard account, params.deleteCard, (err, account)->
        return callback(TextMongooseErrorMessage(err), null, status: 400) if err
        fullCurrentUserJson.accountJson(account, callback)

    else
      account.name = params.name unless _str.isBlank(params.name)
      account.plans = params.plans unless _str.isBlank(params.plans)
      account.save (err)->
        return callback(TextMongooseErrorMessage(err), null, status: 400) if err
        fullCurrentUserJson.accountJson(account, callback)
