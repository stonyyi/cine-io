stripe = require('stripe')(Cine.config('variables/stripe').secretKey)
_str = require 'underscore.string'

module.exports = class EnsureStripeCustomerOnAccount
  constructor: (@account)->
  ensure: (callback)->
    return callback(null, @account) if !_str.isBlank(@account.stripeCustomer.stripeCustomerId)
    stripe.customers.create email: @account.billingEmail, (err, customer)=>
      return callback(err, @account) if err
      @account.stripeCustomer.stripeCustomerId = customer.id
      @account.save(callback)
