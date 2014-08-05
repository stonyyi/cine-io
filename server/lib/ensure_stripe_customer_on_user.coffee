stripe = require('stripe')(Cine.config('variables/stripe').secretKey)
_str = require 'underscore.string'

module.exports = class EnsureStripeCustomerOnUser
  constructor: (@user)->
  ensure: (callback)->
    return callback(null, @user) if !_str.isBlank(@user.stripeCustomer.stripeCustomerId)
    stripe.customers.create email: @user.email, (err, customer)=>
      return callback(err, @user) if err
      @user.stripeCustomer.stripeCustomerId = customer.id
      @user.save(callback)
