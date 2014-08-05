EnsureStripeCustomerOnUser = Cine.server_lib('ensure_stripe_customer_on_user')
User = Cine.server_model('user')

describe 'EnsureStripeCustomerOnUser', ->

  it 'does not call to stripe if the user has a stripeCustomer', (done)->
    user = new User(email: 'the email', name: 'Chillin', stripeCustomer: {stripeCustomerId: 'cus_2ghmxawfvEwXkw'})
    ensurer = new EnsureStripeCustomerOnUser(user)
    ensurer.ensure (err, user)->
      expect(err).to.equal(null)
      expect(user).to.equal(user)
      done()

  it 'will call to stripe if the user does not have a stripeCustomer', (done)->
    stripeSuccess = requireFixture('nock/stripe_create_customer_success')()
    user = new User(plan: 'enterprise', email: 'the email', name: 'Chillin')
    user.save (err, user)->
      expect(err).to.be.null
      ensurer = new EnsureStripeCustomerOnUser(user)
      ensurer.ensure (err, user)->
        expect(err).to.equal(null)
        expect(user).to.equal(user)
        expect(stripeSuccess.isDone()).to.be.true
        expect(user.stripeCustomer.stripeCustomerId).to.equal('cus_2ghmxawfvEwXkw')
        done()
