stripe = require('stripe')(Cine.config('variables/stripe').secretKey)
EnsureStripeCustomerOnAccount = Cine.server_lib('ensure_stripe_customer_on_account')
AddCardToAccountFromStripeToken = Cine.server_lib('add_card_to_account_from_stripe_token')

module.exports = (user, stripeToken, callback)->

  ensureMethodObject = new EnsureStripeCustomerOnAccount(user)
  ensureMethodObject.ensure (err, user)->
    return callback(err, user) if err || !user

    cardAdder = new AddCardToAccountFromStripeToken(user, stripeToken)
    cardAdder.add callback
