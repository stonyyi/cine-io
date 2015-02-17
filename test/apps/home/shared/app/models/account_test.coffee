basicModel = Cine.require 'test/helpers/basic_model'
basicModel('account', urlAttributes: ['masterKey'], id: 'masterKey')
Account = Cine.model('account')

describe 'Account', ->

  describe '#isHeroku', ->
    it 'is true with heroku', ->
      account = new Account(provider: "heroku")
      expect(account.isHeroku()).to.be.true

    it 'is false without heroku', ->
      account = new Account(provider: "cine.io")
      expect(account.isHeroku()).to.be.false

  describe '#isAppdirect', ->
    it 'is true with appdirect', ->
      account = new Account(provider: 'appdirect')
      expect(account.isAppdirect()).to.be.true

    it 'is false without appdirect', ->
      account = new Account(provider: 'cine.io')
      expect(account.isAppdirect()).to.be.false

  describe '#isCine', ->
    it 'is true with appdirect', ->
      account = new Account(provider: 'cine.io')
      expect(account.isCine()).to.be.true

    it 'is false without appdirect', ->
      account = new Account(provider: 'appdirect')
      expect(account.isCine()).to.be.false

  describe 'needsCreditCard', ->
    it 'returns true for an account on a paid broadcast plan without a credit card', ->
      account = new Account(productPlans: {broadcast: ['pro']}, provider: 'cine.io')
      expect(account.needsCreditCard()).to.be.true

    it 'returns true for an account on a paid peer plan without a credit card', ->
      account = new Account(productPlans: {peer: ['pro']}, provider: 'cine.io')
      expect(account.needsCreditCard()).to.be.true

    it 'returns true for an account with at least one paid plan out of multiple plans without a credit card', ->
      account = new Account(productPlans: {broadcast: ['free', 'pro']}, provider: 'cine.io')
      expect(account.needsCreditCard()).to.be.true

    it 'returns true for an account with at least one paid plan without a credit card', ->
      account = new Account(productPlans: {broadcast: ['free'], peer: ['business']}, provider: 'cine.io')
      expect(account.needsCreditCard()).to.be.true

    it 'returns false for an account on a free plan without a credit card', ->
      account = new Account(productPlans: {broadcast: ['free']}, provider: 'cine.io')
      expect(account.needsCreditCard()).to.be.false

    it 'returns false for an account on a pro plan which cannot be disabled', ->
      account = new Account(productPlans: {broadcast: ['pro']}, provider: 'cine.io', cannotBeDisabled: true)
      expect(account.needsCreditCard()).to.be.false

    it 'returns false for an account on a paid plan with a credit card', ->
      account = new Account(productPlans: {broadcast: ['pro']}, provider: 'cine.io', stripeCard: {last4: '4242'})
      expect(account.needsCreditCard()).to.be.false

    it 'returns false for an account on a paid plan without a credit card on a different provider', ->
      account = new Account(productPlans: {broadcast: ['pro']}, provider: 'heroku')
      expect(account.needsCreditCard()).to.be.false

  describe '#isDisabled', ->
    it 'is true for disabled accounts', ->
      account = new Account(isDisabled: true)
      expect(account.isDisabled()).to.be.true

    it 'is false for non-disabled accounts', ->
      account = new Account(isDisabled: false)
      expect(account.isDisabled()).to.be.false

  describe '#updateAccountUrl', ->
    it 'works with cine.io', ->
      account = new Account(provider: 'cine.io')
      expect(account.updateAccountUrl()).to.equal('https://www.cine.io/account')
    it 'works with heroku', ->
      account = new Account(provider: 'heroku')
      expect(account.updateAccountUrl()).to.equal('https://addons.heroku.com/cine')
    it 'works with engineyard', ->
      account = new Account(provider: 'engineyard')
      expect(account.updateAccountUrl()).to.equal('https://addons.engineyard.com/addons/cineio')

    it 'works with appdirect', ->
      account = new Account(provider: 'appdirect', appdirect: {baseUrl: 'the appdirect url'})
      expect(account.updateAccountUrl()).to.equal('the appdirect url')

  describe 'createdAt', ->
    it 'returns a date', ->
      account = new Account(createdAt: (new Date).toISOString())
      expect(account.createdAt()).to.be.instanceOf(Date)

  describe 'broadcastPlans', ->
    it 'returns the broadcastPlans', ->
      account = new Account(productPlans: {broadcast: ['a', 'b', 'c'], peer: ['d', 'e']})
      expect(account.broadcastPlans()).to.deep.equal(['a', 'b', 'c'])

  describe 'peerPlans', ->
    it 'returns the peerPlans', ->
      account = new Account(productPlans: {broadcast: ['a', 'b', 'c'], peer: ['d', 'e']})
      expect(account.peerPlans()).to.deep.equal(['d', 'e'])

  describe 'firstPlan', ->
    it 'returns the first plan', ->
      account = new Account(productPlans: {broadcast: ['a', 'b', 'c']})
      expect(account.firstPlan()).to.equal('a')

  describe 'displayName', ->
    it 'returns the name if available', ->
      account = new Account(name: 'my name', productPlans: {broadcast: ['a', 'b', 'c']})
      expect(account.displayName()).to.equal('my name')

    it 'returns a capitalized first plan if name is not available', ->
      account = new Account(productPlans: {broadcast: ['the b plan', 'c']})
      expect(account.displayName()).to.equal('The b plan')

    it 'returns null if name is not available and plans are not available', ->
      account = new Account()
      expect(account.displayName()).to.be.undefined
