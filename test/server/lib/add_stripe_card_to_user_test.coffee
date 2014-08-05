addStripeCardToUser = Cine.server_lib("add_stripe_card_to_user")
User = Cine.server_model('user')

describe 'addStripeCardToUser', ->

  beforeEach ->
    @addCustomerNock = requireFixture('nock/stripe_create_customer_success')()
    @createCardNock = requireFixture('nock/stripe_create_card_for_customer_success')()

  beforeEach (done)->
    @user = new User(plan: 'enterprise', email: 'the email', name: 'Chillin')
    @user.save done

  beforeEach (done)->
    token = "tok_102gkI2AL5avr9E4wef0ysJa"
    addStripeCardToUser @user, token, (err, user)=>
      @user = user
      done(err)

  it 'ensures the user is a stripe customer', ->
    expect(@user.stripeCustomer.stripeCustomerId).to.equal("cus_2ghmxawfvEwXkw")
    expect(@addCustomerNock.isDone()).to.be.true

  it 'adds the card to the user', ->
    expect(@user.stripeCustomer.cards).to.have.length(1)
    expect(@user.stripeCustomer.cards[0].last4).to.equal("4242")
    expect(@user.stripeCustomer.cards[0].stripeCardId).to.equal("card_102gkI2AL5avr9E4geO0PpkC")
    expect(@createCardNock.isDone()).to.be.true
