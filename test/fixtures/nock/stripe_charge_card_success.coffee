_ = require('underscore')
module.exports = (options={})->
  _.defaults(options, amount: 500, times: 1)
  stripeResponse =
    id: "ch_102dM82AL5avr9E4B8GOejKB"
    object: "charge"
    created: 1380066025
    livemode: false
    paid: true
    amount: options.amount
    currency: "usd"
    refunded: false
    card:
      id: "card_102dM72AL5avr9E4Gj0VJO9b"
      object: "card"
      last4: "4242"
      type: "Visa"
      exp_month: 8
      exp_year: 2015
      fingerprint: "gY3tmLyn6amKYsXg"
      customer: null
      country: "US"
      name: null
      address_line1: null
      address_line2: null
      address_city: null
      address_state: null
      address_zip: null
      address_country: null
      cvc_check: "pass"
      address_line1_check: null
      address_zip_check: null
    captured: true
    refunds: []
    balance_transaction: "txn_102dM82AL5avr9E48fy05Yhz"
    failure_message: null
    failure_code: null
    amount_refunded: 0
    customer: null
    invoice: null
    description: null
    dispute: null

  nock('https://api.stripe.com:443')
    .post('/v1/charges', "amount=#{options.amount}&currency=USD&customer=cus_2ghmxawfvEwXkw&card=card_102gkI2AL5avr9E4geO0PpkC&capture=true")
    .times(options.times)
    .reply(200, JSON.stringify(stripeResponse))
