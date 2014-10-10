calculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')
ProvidersAndPlans = Cine.require('config/providers_and_plans')
calculateAccountBill = Cine.server_lib("billing/calculate_account_bill.coffee")
Account = Cine.server_model("account")
humanizeBytes = Cine.lib('humanize_bytes')

describe "calculateAccountBill", ->
  beforeEach (done)->
    @account = new Account billingProvider: 'cine.io'
    @account.save done

  it "returns 0 for free plans", (done)->
    @account.plans = ['free']
    calculateAccountBill @account, (err, result)->
      expect(err).to.be.null
      expect(result).to.deep.equal(plan: 0, bandwidthOverage: 0, storageOverage: 0)
      done()

  it "returns 100 for basic plan", (done)->
    @account.plans = ['basic']
    calculateAccountBill @account, (err, result)->
      expect(err).to.be.null
      expect(result).to.deep.equal(plan: 100, bandwidthOverage: 0, storageOverage: 0)
      done()

  it "returns 600 for basic and pro plan", (done)->
    @account.plans = ['basic', 'pro']
    calculateAccountBill @account, (err, result)->
      expect(err).to.be.null
      expect(result).to.deep.equal(plan: 600, bandwidthOverage: 0, storageOverage: 0)
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
        @usageStub.callsArgWith(1, null, bandwidth: humanizeBytes.GiB * 150, storage: humanizeBytes.GiB * 25)
        calculateAccountBill @account, (err, result)->
          expect(err).to.be.null
          expect(result).to.deep.equal(plan: 100, bandwidthOverage: 0, storageOverage: 0)
          done()

      it 'returns 600 for basic and pro plans', (done)->
        @account.plans = ['basic', 'pro']
        @usageStub.callsArgWith(1, null, bandwidth: humanizeBytes.GiB * 150 + humanizeBytes.TiB, storage: humanizeBytes.GiB * 25 + humanizeBytes.GiB * 100)
        calculateAccountBill @account, (err, result)->
          expect(err).to.be.null
          expect(result).to.deep.equal(plan: 600, bandwidthOverage: 0, storageOverage: 0)
          done()

    describe 'not within limits', ->
      it 'returns overages for basic plans', (done)->
        @account.plans = ['basic']
        @usageStub.callsArgWith(1, null, bandwidth: humanizeBytes.GiB * 153, storage: humanizeBytes.GiB * 27)
        calculateAccountBill @account, (err, result)->
          expect(err).to.be.null
          expect(result).to.deep.equal(plan: 100, bandwidthOverage: 240, storageOverage: 160)
          done()

      it 'returns overages at the pro rate for basic and pro plans', (done)->
        @account.plans = ['basic', 'pro']
        @usageStub.callsArgWith(1, null, bandwidth: humanizeBytes.GiB * 155 + humanizeBytes.TiB, storage: humanizeBytes.GiB * 29 + humanizeBytes.GiB * 100)
        calculateAccountBill @account, (err, result)->
          expect(err).to.be.null
          expect(result).to.deep.equal(plan: 600, bandwidthOverage: 350, storageOverage: 280)
          done()
