_ = require('underscore')
stripeResponse =
  error:
    type: "invalid_request_error"
    message: "Invalid token id: fake_token"

module.exports = (options={})->
  _.defaults(options, amount: 500, times: 1)
  nock('https://api.stripe.com:443')
    .post('/v1/charges', "amount=#{options.amount}&currency=USD&customer=cus_2ghmxawfvEwXkw&card=card_102gkI2AL5avr9E4geO0PpkC&capture=true")
    .reply(400, JSON.stringify(stripeResponse))
