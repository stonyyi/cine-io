stripeResponse =
  object: "customer"
  created: 1380846753
  id: "cus_2ghmxawfvEwXkw"
  livemode: false
  description: null
  email: "the email"
  delinquent: false
  metadata: {}
  subscription: null
  discount: null
  account_balance: 0
  cards:
    object: "list"
    count: 0
    url: "/v1/customers/cus_2ghmxawfvEwXkw/cards"
    data: []
  default_card: null

module.exports = ->
  nock('https://api.stripe.com:443')
    .post('/v1/customers', "email=the%20email")
    .reply(200, JSON.stringify(stripeResponse))
