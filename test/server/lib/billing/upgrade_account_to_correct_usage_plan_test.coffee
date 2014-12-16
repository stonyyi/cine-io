Account = Cine.server_model("account")
upgradeAccountToCorrectUsagePlan = Cine.server_lib('billing/upgrade_account_to_correct_usage_plan')
humanizeBytes = Cine.lib('humanize_bytes')
assertEmailSent = Cine.require 'test/helpers/assert_email_sent'

describe 'upgradeAccountToCorrectUsagePlan', ->
  beforeEach (done)->
    @account = new Account(billingProvider: 'cine.io', productPlans: {broadcast: ['basic']})
    @account.save done

  assertPlanOnAccount = (account, plan, done)->
    expect(account.productPlans.peer).to.have.length(0)
    expect(account.productPlans.broadcast).to.have.length(1)
    expect(account.productPlans.broadcast[0]).to.equal(plan)
    Account.findById account._id, (err, accountFromDb)->
      expect(err).to.be.null
      expect(accountFromDb.productPlans.peer).to.have.length(0)
      expect(accountFromDb.productPlans.broadcast).to.have.length(1)
      expect(accountFromDb.productPlans.broadcast[0]).to.equal(plan)
      done()

  describe 'with not a cine.io account', ->
    beforeEach (done)->
      @account.billingProvider = 'heroku'
      @account.save done

    it 'rejects non cine.io accounts', (done)->
      upgradeAccountToCorrectUsagePlan @account, {}, (err, account)->
        expect(err).to.equal("cannot upgrade non cine.io accounts")
        done()

  describe 'higher bandwidth', ->

    assertEmailSent 'automaticallyUpgradedAccount'
    assertEmailSent.admin 'automaticallyUpgradedAccount'

    it 'upgrades the account', (done)->
      upgradeAccountToCorrectUsagePlan @account, {bandwidth: humanizeBytes.GiB * 151, storage: 20}, (err, account)->
        expect(err).to.be.null
        assertPlanOnAccount account, 'premium', done

    it 'sends an email to the account', (done)->
      upgradeAccountToCorrectUsagePlan @account, {bandwidth: humanizeBytes.GiB * 151, storage: 20}, (err, account)=>
        expect(err).to.be.null
        expect(@mailerSpies[0].calledOnce).to.be.true
        args = @mailerSpies[0].firstCall.args
        expect(args).to.have.length(3)
        expect(args[0]._id.toString()).to.equal(@account._id.toString())
        expect(args[1]).to.have.length(1)
        expect(args[1][0]).to.equal('basic')
        expect(args[2]).to.be.a('function')
        done()

  describe 'higher storage', ->

    assertEmailSent 'automaticallyUpgradedAccount'
    assertEmailSent.admin 'automaticallyUpgradedAccount'

    it 'upgrades the account', (done)->
      upgradeAccountToCorrectUsagePlan @account, {bandwidth: humanizeBytes.GiB * 151, storage: humanizeBytes.GiB * 151}, (err, account)->
        expect(err).to.be.null
        assertPlanOnAccount account, 'business', done

    it 'sends an email to the account', (done)->
      upgradeAccountToCorrectUsagePlan @account, {bandwidth: humanizeBytes.GiB * 151, storage: humanizeBytes.GiB * 151}, (err, account)=>
        expect(err).to.be.null
        expect(@mailerSpies[0].calledOnce).to.be.true
        args = @mailerSpies[0].firstCall.args
        expect(args).to.have.length(3)
        expect(args[0]._id.toString()).to.equal(@account._id.toString())
        expect(args[1]).to.have.length(1)
        expect(args[1][0]).to.equal('basic')
        expect(args[2]).to.be.a('function')
        done()

  describe 'lower storage and bandwidth', ->
    it 'keeps the account at the same plan', (done)->
      upgradeAccountToCorrectUsagePlan @account, {bandwidth: 10, storage: 20}, (err, account)->
        expect(err).to.be.null
        assertPlanOnAccount account, 'basic', done
