_ = require('underscore')
async = require('async')
billAccountForMonth = Cine.server_lib('billing/bill_account_for_month')
AccountBillingHistory = Cine.server_model("account_billing_history")
calculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')
Account = Cine.server_model("account")
humanizeBytes = Cine.lib('humanize_bytes')
mailer = Cine.server_lib("mailer")
assertEmailSent = Cine.require 'test/helpers/assert_email_sent'

describe 'billAccountForMonth', ->
  beforeEach (done)->
    twoMonthsAgo = new Date
    twoMonthsAgo.setMonth(twoMonthsAgo.getMonth() - 2)
    @account = new Account(plans: ['basic', 'pro'], billingProvider: 'cine.io', createdAt: twoMonthsAgo)
    @account.save done

  beforeEach ->
    @now = new Date

  it 'requires the account be a cine.io account', (done)->
    account = new Account()
    billAccountForMonth account, @now, (err)->
      expect(err).to.equal('can only charge cine.io accounts')
      done()

  describe 'failed to bill', ->
    beforeEach ->
      @usageStub = sinon.stub(calculateAccountUsage, 'byMonth')
      usedBandwidth = humanizeBytes.GiB * 155 + humanizeBytes.TiB
      usedStorage = humanizeBytes.GiB * 29 + humanizeBytes.GiB * 100
      @usageStub.callsArgWith(2, null, bandwidth: usedBandwidth, storage: usedStorage)

    afterEach ->
      @usageStub.restore()

    it 'requires the account be a stripe customer', (done)->
      billAccountForMonth @account, @now, (err)->
        expect(err).to.equal('account not stripe customer')
        done()

    it 'requires the account have a stripe card', (done)->
      @account.stripeCustomer.stripeCustomerId = "the customer id"
      billAccountForMonth @account, @now, (err)->
        expect(err).to.equal('account has no primary card')
        done()

    it 'requires the account have a non deleted stripe card', (done)->
      @account.stripeCustomer.stripeCustomerId = "the customer id"
      @account.stripeCustomer.cards.push stripeCardId: 'some card id', deletedAt: new Date

      billAccountForMonth @account, @now, (err)->
        expect(err).to.equal('account has no primary card')
        done()

  describe 'success', ->
    beforeEach ->
      @usageStub = sinon.stub(calculateAccountUsage, 'byMonth')
      usedBandwidth = humanizeBytes.GiB * 155 + humanizeBytes.TiB
      usedStorage = humanizeBytes.GiB * 29 + humanizeBytes.GiB * 100
      @usageStub.callsArgWith(2, null, bandwidth: usedBandwidth, storage: usedStorage)

    afterEach ->
      @usageStub.restore()

    beforeEach (done)->
      @account.stripeCustomer.stripeCustomerId = "cus_2ghmxawfvEwXkw"
      @account.stripeCustomer.cards.push stripeCardId: "card_102gkI2AL5avr9E4geO0PpkC"
      @account.save done

    beforeEach ->
      @chargeSuccess = requireFixture('nock/stripe_charge_card_success')(amount: 60000 + 350 + 280)
      @templateEmailSuccess = requireFixture('nock/send_template_email_success')()
      @mailerSpy = sinon.spy mailer, 'monthlyBill'

    afterEach ->
      @mailerSpy.restore()

    beforeEach (done)->
      billAccountForMonth @account, @now, done

    it 'creates a record in AccountBillingHistory', (done)->
      AccountBillingHistory.findOne _account: @account._id, (err, abh)=>
        expect(err).to.be.null
        expect(abh.history).to.have.length(1)
        lastCharge = abh.history[0]
        expect(lastCharge.billingDate).to.be.instanceOf(Date)
        expect(lastCharge.billingDate.toString()).to.equal(@now.toString())
        expect(lastCharge.billedAt).to.be.instanceOf(Date)
        expect(lastCharge.paid).to.be.true
        expect(lastCharge.stripeChargeId).to.equal("ch_102dM82AL5avr9E4B8GOejKB")
        expect(lastCharge.mandrillEmailId).to.equal("7af3c15b69ab46cb8fa8ded3370418fa")
        expect(_.invoke(lastCharge.accountPlans, 'toString').sort()).to.deep.equal(['basic', 'pro'])
        expect(_.keys(lastCharge.details).sort()).to.deep.equal(['billing', 'usage'])
        expect(lastCharge.details.billing).to.deep.equal(plan: 60000, bandwidthOverage: 350, storageOverage: 280, prorated: false)
        expect(lastCharge.details.usage).to.deep.equal(bandwidth: humanizeBytes.GiB * 155 + humanizeBytes.TiB, storage: humanizeBytes.GiB * 29 + humanizeBytes.GiB * 100, bandwidthOverage: humanizeBytes.GiB * 5, storageOverage: humanizeBytes.GiB * 4)
        done()

    it 'charges stripe', ->
      expect(@chargeSuccess.isDone()).to.be.true

    it 'sends an email', (done)->
      AccountBillingHistory.findOne _account: @account._id, (err, abh)=>
        expect(err).to.be.null
        expect(@templateEmailSuccess.isDone()).to.be.true
        expect(@mailerSpy.calledOnce).to.be.true
        args = @mailerSpy.firstCall.args
        expect(args).to.have.length(4)
        expect(args[0]._id.toString()).to.equal(@account._id.toString())
        expect(args[1]._id.toString()).to.equal(abh._id.toString())
        expect(args[2].toString()).to.equal(@now.toString())
        expect(args[3]).to.be.a('function')
        done()

  describe 'with a non integer charge amount', ->
    beforeEach ->
      @usageStub = sinon.stub(calculateAccountUsage, 'byMonth')
      usedBandwidth = humanizeBytes.GiB * 12 + 234734338338
      usedStorage = humanizeBytes.GiB * 10
      @usageStub.callsArgWith(2, null, bandwidth: usedBandwidth, storage: usedStorage)

    afterEach ->
      @usageStub.restore()

    beforeEach (done)->
      @account.plans = ['basic']
      @account.createdAt = new Date(@now.toString())
      @account.createdAt.setDate(7)
      @account.stripeCustomer.stripeCustomerId = "cus_2ghmxawfvEwXkw"
      @account.stripeCustomer.cards.push stripeCardId: "card_102gkI2AL5avr9E4geO0PpkC"
      @account.save done

    beforeEach ->
      @chargeSuccess = requireFixture('nock/stripe_charge_card_success')(amount: 16449)
      @templateEmailSuccess = requireFixture('nock/send_template_email_success')()
      @mailerSpy = sinon.spy mailer, 'monthlyBill'

    afterEach ->
      @mailerSpy.restore()

    beforeEach (done)->
      billAccountForMonth @account, @now, done

    it 'creates a record in AccountBillingHistory with a rounded down number', (done)->
      AccountBillingHistory.findOne _account: @account._id, (err, abh)=>
        expect(err).to.be.null
        expect(abh.history).to.have.length(1)
        lastCharge = abh.history[0]
        expect(lastCharge.billingDate).to.be.instanceOf(Date)
        expect(lastCharge.billingDate.toString()).to.equal(@now.toString())
        expect(lastCharge.billedAt).to.be.instanceOf(Date)
        expect(lastCharge.paid).to.be.true
        expect(lastCharge.stripeChargeId).to.equal("ch_102dM82AL5avr9E4B8GOejKB")
        expect(lastCharge.mandrillEmailId).to.equal("7af3c15b69ab46cb8fa8ded3370418fa")
        expect(_.invoke(lastCharge.accountPlans, 'toString').sort()).to.deep.equal(['basic'])
        expect(_.keys(lastCharge.details).sort()).to.deep.equal(['billing', 'usage'])
        expect(lastCharge.details.billing).to.deep.equal(plan: 10000, bandwidthOverage: 6449.071066528559, storageOverage: 0, prorated: false)
        expect(lastCharge.details.usage).to.deep.equal(bandwidth: humanizeBytes.GiB * 12 + 234734338338, storage: humanizeBytes.GiB * 10, bandwidthOverage: 86557966626, storageOverage: 0)
        done()

  describe 'with < 1 GiB of usage', ->
    beforeEach ->
      @usageStub = sinon.stub(calculateAccountUsage, 'byMonth')
      usedBandwidth = humanizeBytes.GiB * 0.9
      usedStorage = humanizeBytes.GiB * 0.9
      @usageStub.callsArgWith(2, null, bandwidth: usedBandwidth, storage: usedStorage)

    afterEach ->
      @usageStub.restore()

    beforeEach ->
      @templateEmailSuccess = requireFixture('nock/send_template_email_success')()
      @mailerSpy = sinon.spy mailer, 'underOneGibBill'

    afterEach ->
      @mailerSpy.restore()

    describe 'with no credit card', ->

      beforeEach (done)->
        billAccountForMonth @account, @now, done

      it 'creates a record in AccountBillingHistory', (done)->
        AccountBillingHistory.findOne _account: @account._id, (err, abh)=>
          expect(err).to.be.null
          expect(abh.history).to.have.length(1)
          lastCharge = abh.history[0]
          expect(lastCharge.billingDate).to.be.instanceOf(Date)
          expect(lastCharge.billingDate.toString()).to.equal(@now.toString())
          expect(lastCharge.billedAt).to.be.instanceOf(Date)
          expect(lastCharge.paid).to.be.undefined
          expect(lastCharge.notCharged).to.be.true
          expect(lastCharge.stripeChargeId).to.be.undefined
          expect(lastCharge.mandrillEmailId).to.equal("7af3c15b69ab46cb8fa8ded3370418fa")
          expect(_.invoke(lastCharge.accountPlans, 'toString').sort()).to.deep.equal(['basic', 'pro'])
          expect(_.keys(lastCharge.details).sort()).to.deep.equal(['billing', 'usage'])
          expect(lastCharge.details.billing).to.deep.equal(plan: 60000, bandwidthOverage: 0, storageOverage: 0, prorated: false)
          expect(lastCharge.details.usage).to.deep.equal(bandwidth: humanizeBytes.GiB * 0.9, storage: humanizeBytes.GiB * 0.9, bandwidthOverage: 0, storageOverage: 0)
          done()

      it 'sends an email that they were not charged', (done)->
        AccountBillingHistory.findOne _account: @account._id, (err, abh)=>
          expect(err).to.be.null
          expect(@templateEmailSuccess.isDone()).to.be.true
          expect(@mailerSpy.calledOnce).to.be.true
          args = @mailerSpy.firstCall.args
          expect(args).to.have.length(4)
          expect(args[0]._id.toString()).to.equal(@account._id.toString())
          expect(args[1]._id.toString()).to.equal(abh._id.toString())
          expect(args[2].toString()).to.equal(@now.toString())
          expect(args[3]).to.be.a('function')
          done()
    describe 'with a credit card', ->
      beforeEach ->
        @chargeSuccess = requireFixture('nock/stripe_charge_card_success')(amount: 60000)

      beforeEach (done)->
        @account.stripeCustomer.stripeCustomerId = "cus_2ghmxawfvEwXkw"
        @account.stripeCustomer.cards.push stripeCardId: "card_102gkI2AL5avr9E4geO0PpkC"
        @account.save done


      beforeEach (done)->
        billAccountForMonth @account, @now, done

      it 'charges stripe', ->
        expect(@chargeSuccess.isDone()).to.be.true

  describe 'with a declined stripe charge', ->
    beforeEach ->
      @usageStub = sinon.stub(calculateAccountUsage, 'byMonth')
      usedBandwidth = humanizeBytes.GiB * 155 + humanizeBytes.TiB
      usedStorage = humanizeBytes.GiB * 29 + humanizeBytes.GiB * 100
      @usageStub.callsArgWith(2, null, bandwidth: usedBandwidth, storage: usedStorage)

    afterEach ->
      @usageStub.restore()

    beforeEach (done)->
      @account.stripeCustomer.stripeCustomerId = "cus_2ghmxawfvEwXkw"
      @account.stripeCustomer.cards.push stripeCardId: "card_102gkI2AL5avr9E4geO0PpkC"
      @account.save done

    beforeEach ->
      @chargeDeclined = requireFixture('nock/stripe_charge_card_declined')(amount: 60000 + 350 + 280)

    assertEmailSent.admin 'cardDeclined'

    beforeEach (done)->
      billAccountForMonth @account, @now, done

    it 'saves the charge error', (done)->
      AccountBillingHistory.findOne _account: @account._id, (err, abh)=>
        expect(err).to.be.null
        expect(abh.history).to.have.length(1)
        lastCharge = abh.history[0]
        expect(lastCharge.billingDate).to.be.instanceOf(Date)
        expect(lastCharge.billingDate.toString()).to.equal(@now.toString())
        expect(lastCharge.billedAt).to.be.instanceOf(Date)
        expect(lastCharge.paid).to.be.false
        expect(lastCharge.stripeChargeId).to.be.undefined
        expect(lastCharge.mandrillEmailId).to.undefined
        expect(lastCharge.chargeError).to.equal('Error: Your card was declined.')
        expect(_.invoke(lastCharge.accountPlans, 'toString').sort()).to.deep.equal(['basic', 'pro'])
        expect(_.keys(lastCharge.details).sort()).to.deep.equal(['billing', 'usage'])
        expect(lastCharge.details.billing).to.deep.equal(plan: 60000, bandwidthOverage: 350, storageOverage: 280, prorated: false)
        expect(lastCharge.details.usage).to.deep.equal(bandwidth: humanizeBytes.GiB * 155 + humanizeBytes.TiB, storage: humanizeBytes.GiB * 29 + humanizeBytes.GiB * 100, bandwidthOverage: humanizeBytes.GiB * 5, storageOverage: humanizeBytes.GiB * 4)
        done()

    it 'sends an email to the admins', (done)->
      AccountBillingHistory.findOne _account: @account._id, (err, abh)=>
        expect(err).to.be.null
        expect(@mailerSpies[0].calledOnce).to.be.true
        args = @mailerSpies[0].firstCall.args
        expect(args).to.have.length(3)
        expect(args[0]._id.toString()).to.equal(@account._id.toString())
        expect(args[1]._id.toString()).to.equal(abh._id.toString())
        expect(args[2].toString()).to.equal(@now.toString())
        done()

  describe 'with a failed stripe charge for an unknown reason', ->
    beforeEach ->
      @usageStub = sinon.stub(calculateAccountUsage, 'byMonth')
      usedBandwidth = humanizeBytes.GiB * 155 + humanizeBytes.TiB
      usedStorage = humanizeBytes.GiB * 29 + humanizeBytes.GiB * 100
      @usageStub.callsArgWith(2, null, bandwidth: usedBandwidth, storage: usedStorage)

    afterEach ->
      @usageStub.restore()

    beforeEach (done)->
      @account.stripeCustomer.stripeCustomerId = "cus_2ghmxawfvEwXkw"
      @account.stripeCustomer.cards.push stripeCardId: "card_102gkI2AL5avr9E4geO0PpkC"
      @account.save done

    beforeEach ->
      @chargeDeclined = requireFixture('nock/stripe_charge_card_failed')(amount: 60000 + 350 + 280)

    assertEmailSent.admin 'unknownChargeError'

    beforeEach (done)->
      billAccountForMonth @account, @now, done

    it 'saves the charge error', (done)->
      AccountBillingHistory.findOne _account: @account._id, (err, abh)=>
        expect(err).to.be.null
        expect(abh.history).to.have.length(1)
        lastCharge = abh.history[0]
        expect(lastCharge.billingDate).to.be.instanceOf(Date)
        expect(lastCharge.billingDate.toString()).to.equal(@now.toString())
        expect(lastCharge.billedAt).to.be.instanceOf(Date)
        expect(lastCharge.paid).to.be.false
        expect(lastCharge.stripeChargeId).to.be.undefined
        expect(lastCharge.mandrillEmailId).to.undefined
        expect(lastCharge.chargeError).to.equal('Error: Invalid token id: fake_token')
        expect(_.invoke(lastCharge.accountPlans, 'toString').sort()).to.deep.equal(['basic', 'pro'])
        expect(_.keys(lastCharge.details).sort()).to.deep.equal(['billing', 'usage'])
        expect(lastCharge.details.billing).to.deep.equal(plan: 60000, bandwidthOverage: 350, storageOverage: 280, prorated: false)
        expect(lastCharge.details.usage).to.deep.equal(bandwidth: humanizeBytes.GiB * 155 + humanizeBytes.TiB, storage: humanizeBytes.GiB * 29 + humanizeBytes.GiB * 100, bandwidthOverage: humanizeBytes.GiB * 5, storageOverage: humanizeBytes.GiB * 4)
        done()

    it 'sends an email to the admins', (done)->
      AccountBillingHistory.findOne _account: @account._id, (err, abh)=>
        expect(err).to.be.null
        expect(@mailerSpies[0].calledOnce).to.be.true
        args = @mailerSpies[0].firstCall.args
        expect(args).to.have.length(3)
        expect(args[0]._id.toString()).to.equal(@account._id.toString())
        expect(args[1]._id.toString()).to.equal(abh._id.toString())
        expect(args[2].toString()).to.equal(@now.toString())
        done()

  describe 'with a current record', ->
    beforeEach (done)->
      @account.stripeCustomer.stripeCustomerId = "cus_2ghmxawfvEwXkw"
      @account.stripeCustomer.cards.push stripeCardId: "card_102gkI2AL5avr9E4geO0PpkC"
      @account.save done

    beforeEach (done)->
      @abh = new AccountBillingHistory(_account: @account._id)
      @abh.history.push billingDate: @now
      @abh.save done

    it 'does not update the account billing history', (done)->
      billAccountForMonth @account, @now, (err, result)=>
        expect(err).be.null
        expect(result).to.equal("already charged account for this month")
        AccountBillingHistory.findOne _account: @account._id, (err, abh)->
          expect(err).to.be.null
          expect(abh.history).to.have.length(1)
          done()
