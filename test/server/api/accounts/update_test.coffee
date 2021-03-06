Account = Cine.server_model('account')
UpdateAccount = testApi Cine.api('accounts/update')
assertEmailSent = Cine.require 'test/helpers/assert_email_sent'

describe 'Accounts#update', ->

  testApi.requiresMasterKey UpdateAccount

  beforeEach (done)->
    @account = new Account(billingProvider: 'cine.io', productPlans: {broadcast: ['pro']}, billingEmail: 'the email', name: 'Chillin')
    @account.save done

  it "updates the account fields", (done)->
    params = {masterKey: @account.masterKey, name: 'New Name', productPlans: {broadcast: ['solo']}}
    callback = (err, response)=>
      expect(err).to.equal(null)
      expect(response.name).to.equal('New Name')
      expect(response.productPlans.peer).to.have.length(0)
      expect(response.productPlans.broadcast).to.have.length(1)
      expect(response.productPlans.broadcast[0]).to.equal('solo')
      Account.findById @account._id, (err, account)->
        expect(account.name).to.equal('New Name')
        expect(account.productPlans.peer).to.have.length(0)
        expect(account.productPlans.broadcast).to.have.length(1)
        expect(account.productPlans.broadcast[0]).to.equal('solo')
        done()

    UpdateAccount params, callback

  describe "won't overwrite with blank values", ->
    it "won't overwrite with blank name", (done)->
      params = {masterKey: @account.masterKey, name: '', productPlans: {broadcast: ['solo']}}
      callback = (err, response)=>
        expect(err).to.equal(null)
        expect(response.name).to.equal('Chillin')
        expect(response.productPlans.peer).to.have.length(0)
        expect(response.productPlans.broadcast).to.have.length(1)
        expect(response.productPlans.broadcast[0]).to.equal('solo')
        Account.findById @account._id, (err, account)->
          expect(account.name).to.equal('Chillin')
          expect(account.productPlans.peer).to.have.length(0)
          expect(account.productPlans.broadcast).to.have.length(1)
          expect(account.productPlans.broadcast[0]).to.equal('solo')
          done()

      UpdateAccount params, callback

    it "won't overwrite with blank plans", (done)->
      params = {masterKey: @account.masterKey, name: 'New Name', productPlans: {broadcast: ''}}
      callback = (err, response)=>
        expect(err).to.equal(null)
        expect(response.name).to.equal('New Name')
        expect(response.productPlans.peer).to.have.length(0)
        expect(response.productPlans.broadcast).to.have.length(1)
        expect(response.productPlans.broadcast[0]).to.equal('pro')
        Account.findById @account._id, (err, account)->
          expect(account.name).to.equal('New Name')
          expect(account.productPlans.peer).to.have.length(0)
          expect(account.productPlans.broadcast).to.have.length(1)
          expect(account.productPlans.broadcast[0]).to.equal('pro')
          done()

      UpdateAccount params, callback

  describe 'adding a credit card', ->
    beforeEach ->
      addCustomerNock = requireFixture('nock/stripe_create_customer_success')()
      createCardNock = requireFixture('nock/stripe_create_card_for_customer_success')()

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

    describe 'with a throttled account', ->
      beforeEach (done)->
        @account.throttledAt = new Date
        @account.save done

      it 'unthrottles an account', (done)->
        params = {masterKey: @account.masterKey, stripeToken: "tok_102gkI2AL5avr9E4wef0ysJa"}
        callback = (err, response)=>
          Account.findById @account._id, (err, account)->
            expect(err).to.be.null
            expect(account.throttledAt).to.be.undefined
            done()

        UpdateAccount params, callback

  describe 'deleting a credit card', ->
    beforeEach (done)->
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
