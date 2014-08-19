stripe = require('stripe')(Cine.config('variables/stripe').secretKey)
_ = require 'underscore'
_.str = require 'underscore.string'

module.exports = class AddCardToAccountFromStripeToken
  constructor: (@account, @stripeToken)->
  add: (callback)->
    return callback('no account') unless @account
    return callback('account is not a stripe customer') if _.str.isBlank(@account.stripeCustomer.stripeCustomerId)
    return callback('no stripe token') if _.str.isBlank(@stripeToken)
    stripe.customers.createCard @account.stripeCustomer.stripeCustomerId, card: @stripeToken, (err, response)=>
      return callback(err) if err
      console.log("got stripe response", response)

      @_addCardToAccount(response)
      @account.save callback

  _addCardToAccount: (response)->
    @account.stripeCustomer.cards.push
      stripeCardId: response.id
      last4: response.last4
      brand: response.brand
      exp_month: response.exp_month
      exp_year: response.exp_year
