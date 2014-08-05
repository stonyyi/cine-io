_ = require('underscore')
deleteStripeCard = Cine.server_lib("delete_stripe_card")
User = Cine.server_model('user')
describe 'deleteStripeCard', ->

  beforeEach (done)->
    @user = new User name: 'Mah name', email: 'mah email', plan: 'free'
    @user.stripeCustomer.cards.push(stripeCardId: 'card_102gkI2AL5avr9E4geO0PpkC')
    @user.stripeCustomer.cards.push(stripeCardId: 'card2')
    @user.save done


  currentCards = (user)->
    _.where(user.stripeCustomer.cards, deletedAt: undefined)

  it 'errors without a card', (done)->
    deleteStripeCard @user, "NOT AN ID", (err, user)=>
      expect(err).to.equal('card not found')
      User.findById @user._id, (err, userFromDb)->
        expect(currentCards(userFromDb)).to.have.length(2)
        done()

  it 'adds deleted at to a card it finds', (done)->
    deleteStripeCard @user, @user.stripeCustomer.cards[0].id, (err, user)=>
      expect(err).to.be.null
      User.findById @user._id, (err, userFromDb)->
        expect(currentCards(userFromDb)).to.have.length(1)
        expect(userFromDb.stripeCustomer.cards[0].deletedAt).to.be.instanceOf(Date)
        done()
