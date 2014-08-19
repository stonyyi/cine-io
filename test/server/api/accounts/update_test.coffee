Account = Cine.server_model('account')
UpdateAccount = testApi Cine.api('accounts/update')
assertEmailSent = Cine.require 'test/helpers/assert_email_sent'

describe 'Accounts#update', ->

  testApi.requiresMasterKey UpdateAccount

  describe 'adding a credit card', ->
    beforeEach ->
      addCustomerNock = requireFixture('nock/stripe_create_customer_success')()
      createCardNock = requireFixture('nock/stripe_create_card_for_customer_success')()

    beforeEach (done)->
      @account = new Account(tempPlan: 'enterprise', billingEmail: 'the email', name: 'Chillin')
      @account.save done

    assertEmailSent.admin 'cardAdded'

    it 'adds a new credit card to the account', (done)->
      params = {masterKey: @account.masterKey, stripeToken: "tok_102gkI2AL5avr9E4wef0ysJa"}
      callback = (err, response)=>
        expect(err).to.equal(null)
        expect(response.stripeCard.last4).to.equal('4242')
        Account.findById @account._id, (err, account)->
          expect(err).to.be.null
          expect(account.stripeCustomer.stripeCustomerId).to.equal('cus_2ghmxawfvEwXkw')
          expect(account.stripeCustomer.cards).to.have.length(1)
          expect(account.stripeCustomer.cards[0].last4).to.equal('4242')
          done()

      UpdateAccount params, callback

    it 'sends a card added email', (done)->
      params = {masterKey: @account.masterKey, stripeToken: "tok_102gkI2AL5avr9E4wef0ysJa"}
      callback = (err, response)=>
        expect(@mailerSpies[0].calledOnce).to.be.true
        expect(@mailerSpies[0].firstCall.args[0].name).to.equal("Chillin")
        done()

      UpdateAccount params, callback

  describe 'deleting a credit card', ->
    beforeEach (done)->
      @account = new Account(tempPlan: 'enterprise', billingEmail: 'the email', name: 'Chillin')
      @account.stripeCustomer.cards.push(stripeCardId: 'card_102gkI2AL5avr9E4geO0PpkC')
      @account.save done

    it 'deletes the credit card', (done)->
      params = {masterKey: @account.masterKey, deleteCard: @account.stripeCustomer.cards[0]._id}
      callback = (err, response)=>
        expect(err).to.equal(null)
        expect(response.stripeCard).to.be.undefined
        Account.findById @account._id, (err, account)->
          expect(err).to.be.null
          expect(account.stripeCustomer.cards).to.have.length(1)
          expect(account.stripeCustomer.cards[0].deletedAt).to.be.instanceOf(Date)
          done()

      UpdateAccount params, callback
