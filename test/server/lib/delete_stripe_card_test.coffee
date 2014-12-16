_ = require('underscore')
deleteStripeCard = Cine.server_lib("delete_stripe_card")
Account = Cine.server_model('account')
describe 'deleteStripeCard', ->

  beforeEach (done)->
    @account = new Account billingProvider: 'cine.io', name: 'Mah name', productPlans: {broadcast: ['free']}
    @account.stripeCustomer.cards.push(stripeCardId: 'card_102gkI2AL5avr9E4geO0PpkC')
    @account.stripeCustomer.cards.push(stripeCardId: 'card2')
    @account.save done


  currentCards = (account)->
    _.where(account.stripeCustomer.cards, deletedAt: undefined)

  it 'errors without a card', (done)->
    deleteStripeCard @account, "NOT AN ID", (err, account)=>
      expect(err).to.equal('card not found')
      Account.findById @account._id, (err, accountFromDb)->
        expect(currentCards(accountFromDb)).to.have.length(2)
        done()

  it 'adds deleted at to a card it finds', (done)->
    deleteStripeCard @account, @account.stripeCustomer.cards[0].id, (err, account)=>
      expect(err).to.be.null
      Account.findById @account._id, (err, accountFromDb)->
        expect(currentCards(accountFromDb)).to.have.length(1)
        expect(accountFromDb.stripeCustomer.cards[0].deletedAt).to.be.instanceOf(Date)
        done()
