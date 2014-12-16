_ = require('underscore')
calculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')
calculateAccountBill = Cine.server_lib("billing/calculate_account_bill.coffee")
Account = Cine.server_model("account")
humanizeBytes = Cine.lib('humanize_bytes')

describe "calculateAccountBill", ->
  beforeEach (done)->
    accountCreatedDate = new Date
    accountCreatedDate.setMonth(accountCreatedDate.getMonth() - 2)
    @account = new Account billingProvider: 'cine.io', createdAt: accountCreatedDate
    @account.save done

  beforeEach ->
    @month = new Date

  it "returns 0 for no plans", (done)->
    @account.productPlans = {broadcast: []}
    calculateAccountBill @account, @month, (err, result)->
      expect(err).to.be.null
      expect(_.keys(result).sort()).to.deep.equal(['billing', 'usage'])
      expect(result.billing).to.deep.equal(plan: 0, prorated: false)
      expect(result.usage).to.deep.equal(bandwidth: 0, storage: 0)
      done()

  it "returns 0 for free plans", (done)->
    @account.productPlans = {broadcast: ['free']}
    calculateAccountBill @account, @month, (err, result)->
      expect(err).to.be.null
      expect(_.keys(result).sort()).to.deep.equal(['billing', 'usage'])
      expect(result.billing).to.deep.equal(plan: 0, prorated: false)
      expect(result.usage).to.deep.equal(bandwidth: 0, storage: 0)
      done()

  it "returns 100 for basic plan", (done)->
    @account.productPlans = {broadcast: ['basic']}
    calculateAccountBill @account, @month, (err, result)->
      expect(err).to.be.null
      expect(_.keys(result).sort()).to.deep.equal(['billing', 'usage'])
      expect(result.billing).to.deep.equal(plan: 10000, prorated: false)
      expect(result.usage).to.deep.equal(bandwidth: 0, storage: 0)
      done()

  it "returns 600 for basic and pro plan", (done)->
    @account.productPlans = {broadcast: ['basic', 'pro']}
    calculateAccountBill @account, @month, (err, result)->
      expect(err).to.be.null
      expect(_.keys(result).sort()).to.deep.equal(['billing', 'usage'])
      expect(result.billing).to.deep.equal(plan: 60000, prorated: false)
      expect(result.usage).to.deep.equal(bandwidth: 0, storage: 0)
      done()

  describe 'with bandwidth and storage', ->

    beforeEach ->
      @usageStub = sinon.stub(calculateAccountUsage, 'byMonth')

    afterEach ->
      expect(@usageStub.calledOnce).to.be.true
      args = @usageStub.firstCall.args
      expect(args).to.have.length(3)
      expect(args[0]._id.toString()).to.equal(@account._id.toString())
      expect(args[1].toString()).to.equal(@month.toString())
      expect(args[2]).to.be.an.instanceOf(Function)
      @usageStub.restore()

    describe 'within limits', ->
      it 'returns 100 for basic plans', (done)->
        @account.productPlans = {broadcast: ['basic']}
        usedBandwidth = humanizeBytes.GiB * 150
        usedStorage = humanizeBytes.GiB * 25
        @usageStub.callsArgWith(2, null, bandwidth: usedBandwidth, storage: usedStorage)
        calculateAccountBill @account, @month, (err, result)->
          expect(err).to.be.null
          expect(_.keys(result).sort()).to.deep.equal(['billing', 'usage'])
          expect(result.billing).to.deep.equal(plan: 10000, prorated: false)
          expect(result.usage).to.deep.equal(bandwidth: usedBandwidth, storage: usedStorage)
          done()

      it 'returns 600 for basic and pro plans', (done)->
        @account.productPlans = {broadcast: ['basic', 'pro']}
        usedBandwidth = humanizeBytes.GiB * 150 + humanizeBytes.TiB
        usedStorage = humanizeBytes.GiB * 25 + humanizeBytes.GiB * 100
        @usageStub.callsArgWith(2, null, bandwidth: usedBandwidth, storage: usedStorage)
        calculateAccountBill @account, @month, (err, result)->
          expect(err).to.be.null
          expect(_.keys(result).sort()).to.deep.equal(['billing', 'usage'])
          expect(result.billing).to.deep.equal(plan: 60000, prorated: false)
          expect(result.usage).to.deep.equal(bandwidth: usedBandwidth, storage: usedStorage)
          done()

    describe 'signed up within the month', ->
      beforeEach (done)->
        @month.setDate(15)
        @month.setMonth(0)
        @account.createdAt = @month
        @account.productPlans = {broadcast: ['basic', 'pro']}
        @account.save done

      it 'charges them a prorated amount when they are under 1 Gib', (done)->
        usedBandwidth = humanizeBytes.GiB * 0.8
        usedStorage = humanizeBytes.GiB * 0.5
        @usageStub.callsArgWith(2, null, bandwidth: usedBandwidth, storage: usedStorage)
        calculateAccountBill @account, @month, (err, result)->
          expect(err).to.be.null
          expect(_.keys(result).sort()).to.deep.equal(['billing', 'usage'])
          daysActiveInMonth = 17
          percentageOfMonthWereThrough = daysActiveInMonth / 31
          expect(result.billing).to.deep.equal(plan: 60000 * (percentageOfMonthWereThrough), prorated: true)
          expect(result.usage).to.deep.equal(bandwidth: usedBandwidth, storage: usedStorage)
          done()

      it 'charges them a full amount when they are at usage', (done)->
        usedBandwidth = humanizeBytes.GiB * 2
        usedStorage = humanizeBytes.GiB * 3
        @usageStub.callsArgWith(2, null, bandwidth: usedBandwidth, storage: usedStorage)
        calculateAccountBill @account, @month, (err, result)->
          expect(err).to.be.null
          expect(_.keys(result).sort()).to.deep.equal(['billing', 'usage'])
          expect(result.billing).to.deep.equal(plan: 60000, prorated: false)
          expect(result.usage).to.deep.equal(bandwidth: usedBandwidth, storage: usedStorage)
          done()
