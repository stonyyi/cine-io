stripeResponse =
  id: "card_102gkI2AL5avr9E4geO0PpkC"
  object: "card"
  last4: "4242"
  brand: 'Visa'
  funding: 'credit'
  exp_month: 12
  exp_year: 2015
  fingerprint: "gY3tmLyn6amKYsXg"
  customer: "cus_2ghmxawfvEwXkw"
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

module.exports = ->
  nock('https://api.stripe.com:443')
    .post('/v1/customers/cus_2ghmxawfvEwXkw/cards', "card=tok_102gkI2AL5avr9E4wef0ysJa")
    .reply(200, JSON.stringify(stripeResponse))
