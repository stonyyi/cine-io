stripe = require('stripe')(Cine.config('variables/stripe').secretKey)
EnsureStripeCustomerOnUser = Cine.server_lib('ensure_stripe_customer_on_user')
AddCardToUserFromStripeToken = Cine.server_lib('add_card_to_user_from_stripe_token')

module.exports = (user, stripeToken, callback)->

  ensureMethodObject = new EnsureStripeCustomerOnUser(user)
  ensureMethodObject.ensure (err, user)->
    return callback(err, user) if err || !user

    cardAdder = new AddCardToUserFromStripeToken(user, stripeToken)
    cardAdder.add callback
