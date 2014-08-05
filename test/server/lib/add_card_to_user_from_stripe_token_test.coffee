AddCardToUserFromStripeToken = Cine.server_lib('add_card_to_user_from_stripe_token')
User = Cine.server_model('user')

describe 'AddCardToUserFromStripeToken', ->

  describe 'valid input', ->

    it 'creates a card object on the user', (done)->
      stripeSuccess = requireFixture('nock/stripe_create_card_for_customer_success')()
      user = new User(plan: 'enterprise', email: 'the email', stripeCustomer: {stripeCustomerId: 'cus_2ghmxawfvEwXkw'})
      caller = new AddCardToUserFromStripeToken(user, 'tok_102gkI2AL5avr9E4wef0ysJa')
      caller.add (err, user, card)->
        expect(err).to.equal(null)
        expect(user).to.equal(user)
        card = user.stripeCustomer.cards[0]
        expect(card.stripeCardId).to.equal('card_102gkI2AL5avr9E4geO0PpkC')
        expect(card.last4).to.equal('4242')
        expect(card.brand).to.equal('Visa')
        expect(card.exp_month).equal(12)
        expect(card.exp_year).to.equal(2015)
        expect(stripeSuccess.isDone()).to.be.true
        done()

  describe 'invalid input', ->
    it 'requires a user', (done)->
      caller = new AddCardToUserFromStripeToken(null, 'fake token')
      caller.add (err, user, card)->
        expect(err).to.equal("no user")
        expect(user).to.equal(undefined)
        expect(card).to.equal(undefined)
        done()

    it 'requires a user be a stripe customer', (done)->
      user = new User(stripeCustomer: {stripeCustomerId: ''})
      caller = new AddCardToUserFromStripeToken(user, 'fake token')
      caller.add (err, user, card)->
        expect(err).to.equal("user is not a stripe customer")
        expect(user).to.equal(undefined)
        expect(card).to.equal(undefined)
        done()
    it 'requires a stripe token', (done)->
      user = new User(stripeCustomer: {stripeCustomerId: 'fake customer'})
      caller = new AddCardToUserFromStripeToken(user, '')
      caller.add (err, user, card)->
        expect(err).to.equal("no stripe token")
        expect(user).to.equal(undefined)
        expect(card).to.equal(undefined)
        done()
