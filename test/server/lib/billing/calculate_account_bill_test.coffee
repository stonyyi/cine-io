_ = require('underscore')
calculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')
calculateAccountBill = Cine.server_lib("billing/calculate_account_bill.coffee")
Account = Cine.server_model("account")
humanizeBytes = Cine.lib('humanize_bytes')

describe "calculateAccountBill", ->
  beforeEach (done)->
    @account = new Account billingProvider: 'cine.io'
    @account.save done

  it "returns 0 for no plans", (done)->
    @account.plans = []
    calculateAccountBill @account, (err, result)->
      expect(err).to.be.null
      expect(_.keys(result).sort()).to.deep.equal(['billing', 'usage'])
      expect(result.billing).to.deep.equal(plan: 0, bandwidthOverage: 0, storageOverage: 0)
      expect(result.usage).to.deep.equal(bandwidth: 0, storage: 0, bandwidthOverage: 0, storageOverage: 0)
      done()

  it "returns 0 for free plans", (done)->
    @account.plans = ['free']
    calculateAccountBill @account, (err, result)->
      expect(err).to.be.null
      expect(_.keys(result).sort()).to.deep.equal(['billing', 'usage'])
      expect(result.billing).to.deep.equal(plan: 0, bandwidthOverage: 0, storageOverage: 0)
      expect(result.usage).to.deep.equal(bandwidth: 0, storage: 0, bandwidthOverage: 0, storageOverage: 0)
      done()

  it "returns 100 for basic plan", (done)->
    @account.plans = ['basic']
    calculateAccountBill @account, (err, result)->
      expect(err).to.be.null
      expect(_.keys(result).sort()).to.deep.equal(['billing', 'usage'])
      expect(result.billing).to.deep.equal(plan: 10000, bandwidthOverage: 0, storageOverage: 0)
      expect(result.usage).to.deep.equal(bandwidth: 0, storage: 0, bandwidthOverage: 0, storageOverage: 0)
      done()

  it "returns 600 for basic and pro plan", (done)->
    @account.plans = ['basic', 'pro']
    calculateAccountBill @account, (err, result)->
      expect(err).to.be.null
      expect(_.keys(result).sort()).to.deep.equal(['billing', 'usage'])
      expect(result.billing).to.deep.equal(plan: 60000, bandwidthOverage: 0, storageOverage: 0)
      expect(result.usage).to.deep.equal(bandwidth: 0, storage: 0, bandwidthOverage: 0, storageOverage: 0)
      done()

  describe 'with bandwidth and storage', ->

    beforeEach ->
      @usageStub = sinon.stub(calculateAccountUsage, 'thisMonth')

    afterEach ->
      expect(@usageStub.calledOnce).to.be.true
      args = @usageStub.firstCall.args
      expect(args).to.have.length(2)
      expect(args[0]._id.toString()).to.equal(@account._id.toString())
      expect(args[1]).to.be.an.instanceOf(Function)
      @usageStub.restore()

    describe 'within limits', ->
      it 'returns 100 for basic plans', (done)->
        @account.plans = ['basic']
        usedBandwidth = humanizeBytes.GiB * 150
        usedStorage = humanizeBytes.GiB * 25
        @usageStub.callsArgWith(1, null, bandwidth: usedBandwidth, storage: usedStorage)
        calculateAccountBill @account, (err, result)->
          expect(err).to.be.null
          expect(_.keys(result).sort()).to.deep.equal(['billing', 'usage'])
          expect(result.billing).to.deep.equal(plan: 10000, bandwidthOverage: 0, storageOverage: 0)
          expect(result.usage).to.deep.equal(bandwidth: usedBandwidth, storage: usedStorage, bandwidthOverage: 0, storageOverage: 0)
          done()

      it 'returns 600 for basic and pro plans', (done)->
        @account.plans = ['basic', 'pro']
        usedBandwidth = humanizeBytes.GiB * 150 + humanizeBytes.TiB
        usedStorage = humanizeBytes.GiB * 25 + humanizeBytes.GiB * 100
        @usageStub.callsArgWith(1, null, bandwidth: usedBandwidth, storage: usedStorage)
        calculateAccountBill @account, (err, result)->
          expect(err).to.be.null
          expect(_.keys(result).sort()).to.deep.equal(['billing', 'usage'])
          expect(result.billing).to.deep.equal(plan: 60000, bandwidthOverage: 0, storageOverage: 0)
          expect(result.usage).to.deep.equal(bandwidth: usedBandwidth, storage: usedStorage, bandwidthOverage: 0, storageOverage: 0)
          done()

    describe 'not within limits', ->
      it 'returns overages for basic plans', (done)->
        @account.plans = ['basic']
        usedBandwidth = humanizeBytes.GiB * 153
        usedStorage = humanizeBytes.GiB * 27
        @usageStub.callsArgWith(1, null, bandwidth: usedBandwidth, storage: usedStorage)
        calculateAccountBill @account, (err, result)->
          expect(err).to.be.null
          expect(_.keys(result).sort()).to.deep.equal(['billing', 'usage'])
          expect(result.billing).to.deep.equal(plan: 10000, bandwidthOverage: 240, storageOverage: 160)
          expect(result.usage).to.deep.equal(bandwidth: usedBandwidth, storage: usedStorage, bandwidthOverage: humanizeBytes.GiB * 3, storageOverage: humanizeBytes.GiB * 2)
          done()

      it 'returns overages at the pro rate for basic and pro plans', (done)->
        @account.plans = ['basic', 'pro']
        usedBandwidth = humanizeBytes.GiB * 155 + humanizeBytes.TiB
        usedStorage = humanizeBytes.GiB * 29 + humanizeBytes.GiB * 100
        @usageStub.callsArgWith(1, null, bandwidth: usedBandwidth, storage: usedStorage)
        calculateAccountBill @account, (err, result)->
          expect(err).to.be.null
          expect(_.keys(result).sort()).to.deep.equal(['billing', 'usage'])
          expect(result.billing).to.deep.equal(plan: 60000, bandwidthOverage: 350, storageOverage: 280)
          expect(result.usage).to.deep.equal(bandwidth: usedBandwidth, storage: usedStorage, bandwidthOverage: humanizeBytes.GiB * 5, storageOverage: humanizeBytes.GiB * 4)
          done()

  describe '.cheapestOverageCost', ->
    it 'returns the cheapest cost for an account with one plan', ->
      account = new Account(billingProvider: 'cine.io', plans: ['basic'])
      expect(calculateAccountBill.cheapestOverageCost(account, 'bandwidth')).to.equal(80)
      expect(calculateAccountBill.cheapestOverageCost(account, 'storage')).to.equal(80)
    it 'returns the cheapest cost for an account with two plans', ->
      account = new Account(billingProvider: 'cine.io', plans: ['basic', 'pro'])
      expect(calculateAccountBill.cheapestOverageCost(account, 'bandwidth')).to.equal(70)
      expect(calculateAccountBill.cheapestOverageCost(account, 'storage')).to.equal(70)
