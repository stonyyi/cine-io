stripe = require('stripe')(Cine.config('variables/stripe').secretKey)
_ = require 'underscore'
_.str = require 'underscore.string'

module.exports = class AddCardToUserFromStripeToken
  constructor: (@user, @stripeToken)->
  add: (callback)->
    return callback('no user') unless @user
    return callback('user is not a stripe customer') if _.str.isBlank(@user.stripeCustomer.stripeCustomerId)
    return callback('no stripe token') if _.str.isBlank(@stripeToken)
    stripe.customers.createCard @user.stripeCustomer.stripeCustomerId, card: @stripeToken, (err, response)=>
      return callback(err) if err
      console.log("got stripe response", response)

      @_addCardToUser(response)
      @user.save callback

  _addCardToUser: (response)->
    @user.stripeCustomer.cards.push
      stripeCardId: response.id
      last4: response.last4
      brand: response.brand
      exp_month: response.exp_month
      exp_year: response.exp_year
