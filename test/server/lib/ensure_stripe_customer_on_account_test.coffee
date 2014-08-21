EnsureStripeCustomerOnAccount = Cine.server_lib('ensure_stripe_customer_on_account')
Account = Cine.server_model('account')

describe 'EnsureStripeCustomerOnAccount', ->

  it 'does not call to stripe if the account has a stripeCustomer', (done)->
    account = new Account(tempPlan: 'pro', billingEmail: 'the email', name: 'Chillin', stripeCustomer: {stripeCustomerId: 'da-stripe-customer'})
    ensurer = new EnsureStripeCustomerOnAccount(account)
    ensurer.ensure (err, account)->
      expect(err).to.equal(null)
      expect(account.stripeCustomer.stripeCustomerId).to.equal('da-stripe-customer')
      done()

  it 'will call to stripe if the account does not have a stripeCustomer', (done)->
    stripeSuccess = requireFixture('nock/stripe_create_customer_success')()
    account = new Account(tempPlan: 'pro', billingEmail: 'the email', name: 'Chillin')
    account.save (err, account)->
      expect(err).to.be.null
      ensurer = new EnsureStripeCustomerOnAccount(account)
      ensurer.ensure (err, account)->
        expect(err).to.equal(null)
        expect(stripeSuccess.isDone()).to.be.true
        expect(account.stripeCustomer.stripeCustomerId).to.equal('cus_2ghmxawfvEwXkw')
        done()
