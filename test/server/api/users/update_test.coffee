User = Cine.server_model('user')
UpdateUser = testApi Cine.api('users/update')
assertEmailSent = Cine.require 'test/helpers/assert_email_sent'

describe 'Users#update', ->

  beforeEach (done)->
    @user = new User name: 'Mah name', email: 'mah email', plan: 'free'
    @user.save done

  beforeEach (done)->
    @user2 = new User name: 'Second name', email: 'second email', plan: 'free'
    @user2.save done

  it 'requires the user be logged in', (done)->
    params = {}
    session = {}
    callback = (err, response, options)->
      expect(err).to.equal("not logged in")
      expect(response).to.equal(null)
      expect(options.status).to.equal(401)
      done()

    UpdateUser params, session, callback

  it 'cannot update the user from a different normal account', (done)->
    params = {id: @user._id}
    session = {user: @user2}
    callback = (err, response, options)->
      expect(err).to.equal("unauthorized")
      expect(response).to.equal(null)
      expect(options.status).to.equal(401)
      done()

    UpdateUser params, session, callback

  describe 'logged in as user', ->

    it "updates the user fields", (done)->
      params = {id: @user._id, name: 'New Name', email: 'new email'}
      session = {user: @user}
      callback = (err, response)=>
        expect(err).to.equal(null)
        expect(response.name).to.equal('New Name')
        expect(response.email).to.equal('new email')
        User.findById @user._id, (err, user)->
          expect(user.name).to.equal('New Name')
          expect(user.email).to.equal('new email')
          done()

      UpdateUser params, session, callback

    describe "won't overwrite with blank values", ->
      it "won't overwrite with blank name", (done)->
        params = {id: @user._id, name: '', email: 'new email'}
        session = {user: @user}
        callback = (err, response)=>
          expect(err).to.equal(null)
          expect(response.name).to.equal('Mah name')
          expect(response.email).to.equal('new email')
          User.findById @user._id, (err, user)->
            expect(user.name).to.equal('Mah name')
            expect(user.email).to.equal('new email')
            done()

        UpdateUser params, session, callback

      it "won't overwrite with blank email", (done)->
        params = {id: @user._id, name: 'New Name', email: ''}
        session = {user: @user}
        callback = (err, response)=>
          expect(err).to.equal(null)
          expect(response.name).to.equal('New Name')
          expect(response.email).to.equal('mah email')
          User.findById @user._id, (err, user)->
            expect(user.name).to.equal('New Name')
            expect(user.email).to.equal('mah email')
            done()

        UpdateUser params, session, callback

  describe 'sending the welcome email', ->
    assertEmailSent 'welcomeEmail'
    assertEmailSent.admin 'newUser'

    it 'sends a welcome email', (done)->
      params = {id: @user._id, name: 'My Name', completedsignup: 'local'}
      session = {user: @user}
      callback = (err, response)=>
        expect(@mailerSpies[0].calledOnce).to.be.true
        expect(@mailerSpies[0].firstCall.args[0].name).to.equal("My Name")
        expect(@mailerSpies[1].calledOnce).to.be.true
        expect(@mailerSpies[1].firstCall.args[0].name).to.equal("My Name")
        done()

      UpdateUser params, session, callback

  describe 'adding a credit card', ->
    beforeEach ->
      addCustomerNock = requireFixture('nock/stripe_create_customer_success')()
      createCardNock = requireFixture('nock/stripe_create_card_for_customer_success')()

    beforeEach (done)->
      @user = new User(plan: 'enterprise', email: 'the email', name: 'Chillin')
      @user.save done

    it 'adds a new credit card to the user', (done)->
      params = {id: @user._id, stripeToken: "tok_102gkI2AL5avr9E4wef0ysJa"}
      session = {user: @user}
      callback = (err, response)=>
        expect(err).to.equal(null)
        expect(response.stripeCard.last4).to.equal('4242')
        User.findById @user._id, (err, user)->
          expect(err).to.be.null
          expect(user.stripeCustomer.stripeCustomerId).to.equal('cus_2ghmxawfvEwXkw')
          expect(user.stripeCustomer.cards).to.have.length(1)
          expect(user.stripeCustomer.cards[0].last4).to.equal('4242')
          done()

      UpdateUser params, session, callback
