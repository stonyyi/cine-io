addStripeCardToAccount = Cine.server_lib("add_stripe_card_to_account")
Account = Cine.server_model('account')

describe 'addStripeCardToAccount', ->

  beforeEach ->
    @addCustomerNock = requireFixture('nock/stripe_create_customer_success')()
    @createCardNock = requireFixture('nock/stripe_create_card_for_customer_success')()

  beforeEach (done)->
    @account = new Account(plans: ['pro'], billingEmail: 'the email', name: 'Chillin')
    @account.save done

  beforeEach (done)->
    token = "tok_102gkI2AL5avr9E4wef0ysJa"
    addStripeCardToAccount @account, token, (err, account)=>
      @account = account
      done(err)

  it 'ensures the account is a stripe customer', ->
    expect(@account.stripeCustomer.stripeCustomerId).to.equal("cus_2ghmxawfvEwXkw")
    expect(@addCustomerNock.isDone()).to.be.true

  it 'adds the card to the account', ->
    expect(@account.stripeCustomer.cards).to.have.length(1)
    expect(@account.stripeCustomer.cards[0].last4).to.equal("4242")
    expect(@account.stripeCustomer.cards[0].stripeCardId).to.equal("card_102gkI2AL5avr9E4geO0PpkC")
    expect(@createCardNock.isDone()).to.be.true
