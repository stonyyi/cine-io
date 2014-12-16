AddCardToAccountFromStripeToken = Cine.server_lib('add_card_to_account_from_stripe_token')
Account = Cine.server_model('account')

describe 'AddCardToAccountFromStripeToken', ->

  describe 'valid input', ->

    it 'creates a card object on the account', (done)->
      stripeSuccess = requireFixture('nock/stripe_create_card_for_customer_success')()
      account = new Account(billingProvider: 'cine.io', productPlans: {broadcast: ['pro']}, billingEmail: 'the email', stripeCustomer: {stripeCustomerId: 'cus_2ghmxawfvEwXkw'})
      caller = new AddCardToAccountFromStripeToken(account, 'tok_102gkI2AL5avr9E4wef0ysJa')
      caller.add (err, account, card)->
        expect(err).to.equal(null)
        expect(account).to.equal(account)
        card = account.stripeCustomer.cards[0]
        expect(card.stripeCardId).to.equal('card_102gkI2AL5avr9E4geO0PpkC')
        expect(card.last4).to.equal('4242')
        expect(card.brand).to.equal('Visa')
        expect(card.exp_month).equal(12)
        expect(card.exp_year).to.equal(2015)
        expect(stripeSuccess.isDone()).to.be.true
        done()

  describe 'invalid input', ->
    it 'requires a account', (done)->
      caller = new AddCardToAccountFromStripeToken(null, 'fake token')
      caller.add (err, account, card)->
        expect(err).to.equal("no account")
        expect(account).to.equal(undefined)
        expect(card).to.equal(undefined)
        done()

    it 'requires a account be a stripe customer', (done)->
      account = new Account(billingProvider: 'cine.io', stripeCustomer: {stripeCustomerId: ''})
      caller = new AddCardToAccountFromStripeToken(account, 'fake token')
      caller.add (err, account, card)->
        expect(err).to.equal("account is not a stripe customer")
        expect(account).to.equal(undefined)
        expect(card).to.equal(undefined)
        done()
    it 'requires a stripe token', (done)->
      account = new Account(billingProvider: 'cine.io', stripeCustomer: {stripeCustomerId: 'fake customer'})
      caller = new AddCardToAccountFromStripeToken(account, '')
      caller.add (err, account, card)->
        expect(err).to.equal("no stripe token")
        expect(account).to.equal(undefined)
        expect(card).to.equal(undefined)
        done()
