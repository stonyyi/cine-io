notifyAccountsThreeDaysAfterSigningUp = Cine.server_lib('notify_accounts_three_days_after_signing_up')
Account = Cine.server_model('account')
Project = Cine.server_model('project')
AccountEmailHistory = Cine.server_model('account_email_history')
assertEmailSent = Cine.require 'test/helpers/assert_email_sent'
CalculateAccountBandwidth = Cine.server_lib('reporting/broadcast/calculate_account_bandwidth')

daysAgoAtMidnight = (daysAgo)->
  d = new Date
  d.setHours(0)
  d.setMinutes(0)
  d.setSeconds(0)
  d.setMilliseconds(0)
  d.setDate(d.getDate() - daysAgo)
  d

describe 'notify_account_three_days_after_signing_up', ->

  beforeEach ->
    @threeDaysAgo = new Date
    @threeDaysAgo.setDate(@threeDaysAgo.getDate() - 3)

  beforeEach (done)->
    @notSignedUpThreeDaysAgo = new Account billingEmail: 'some email', billingProvider: 'cine.io', plans: {peer: ['free'], broadcast: ['free']}
    @notSignedUpThreeDaysAgo.save done

  beforeEach (done)->
    @notDoneAnything = new Account billingEmail: 'some email', billingProvider: 'cine.io', plans: {peer: ['free'], broadcast: ['free']}, createdAt: @threeDaysAgo
    @notDoneAnything.save done

  beforeEach (done)->
    @alreadyGotEmail = new Account billingEmail: 'some email2', billingProvider: 'cine.io', plans: {peer: ['free'], broadcast: ['free']}, createdAt: @threeDaysAgo
    @alreadyGotEmail.save done

  beforeEach (done)->
    aeh = new AccountEmailHistory _account: @alreadyGotEmail._id
    aeh.history.push
      kind: 'threeDayNotification'
      sentAt: new Date
    aeh.save done

  beforeEach (done)->
    @onlyPeer = new Account billingProvider: 'cine.io',billingEmail: 'some email', createdAt: @threeDaysAgo
    @onlyPeer.save done

  beforeEach (done)->
    @onlyBroadcast = new Account billingProvider: 'cine.io',billingEmail: 'some email', createdAt: @threeDaysAgo
    @onlyBroadcast.save done

  beforeEach (done)->
    @notDoneAnythingProject = new Project _account: @notDoneAnything._id
    @notDoneAnythingProject.save(done)

  beforeEach (done)->
    @onlyPeerProject = new Project _account: @onlyPeer._id
    @onlyPeerProject.save(done)

  beforeEach (done)->
    @onlyBroadcastProject = new Project _account: @onlyBroadcast._id
    @onlyBroadcastProject.save(done)

  beforeEach (done)->
    results =
      projectId: @onlyPeerProject._id.toString()
      result: 454545
    response =
      [results]

    threeDaysAgo = daysAgoAtMidnight(3)
    twoDaysAgo = daysAgoAtMidnight(2)

    requireFixture('nock/keen/sum_peer_milliseconds_group_by_project') response, threeDaysAgo, twoDaysAgo, (err, @keenNock2)=>
      done(err)

  beforeEach ->
    @keenSuccess = requireFixture('nock/keen/status_check_success')()

  beforeEach ->
    @fakeBandwidthByMonth = {}
    @fakeBandwidthByMonth[@onlyBroadcast._id.toString()] = 99999

    @bandwidthStub = sinon.stub CalculateAccountBandwidth, 'byMonth', (account, month, callback)=>
      resource = @fakeBandwidthByMonth
      callback(null, resource[account._id.toString()] || 0)

  afterEach ->
    @bandwidthStub.restore()

  assertEmailSent 'haventDoneAnything'
  assertEmailSent 'didSendBandwidth'
  assertEmailSent 'didSendPeer'

  it "will return the result from the run", (done)->
    expected =
      didNothing: [@notDoneAnything._id]
      didSendPeer: [@onlyPeer._id]
      didSendBandwidth: [@onlyBroadcast._id]
      unknown: []

    notifyAccountsThreeDaysAfterSigningUp (err, results)=>
      expect(err).to.be.null
      expect(results).to.deep.equal(expected)
      done()

  it "will notify an account if they haven't streamed anything nor had peer minutes", (done)->
    notifyAccountsThreeDaysAfterSigningUp (err, results)=>
      expect(err).to.be.null
      AccountEmailHistory.findOne _account: @notDoneAnything._id, (err, aeh)=>
        expect(err).to.be.null
        expect(aeh).to.be.ok
        result = aeh.findKind('threeDayNotification')
        expect(result).to.be.ok
        expect(@mailerSpies[0].calledOnce).to.be.true
        expect(@mailerSpies[0].firstCall.args[0]._id).to.deep.equal(@notDoneAnything._id)
        done()

  it "will not notify an account if they have received an email already", (done)->
    notifyAccountsThreeDaysAfterSigningUp (err, results)=>
      expect(err).to.be.null
      AccountEmailHistory.findOne _account: @alreadyGotEmail._id, (err, aeh)=>
        expect(err).to.be.null
        expect(aeh).to.be.ok
        result = aeh.findKind('threeDayNotification')
        expect(result).to.be.ok
        done()

  it "will thank an account for streaming if they have streamed", (done)->
    notifyAccountsThreeDaysAfterSigningUp (err, results)=>
      expect(err).to.be.null
      AccountEmailHistory.findOne _account: @onlyBroadcast._id, (err, aeh)=>
        expect(err).to.be.null
        expect(aeh).to.be.ok
        result = aeh.findKind('threeDayNotification')
        expect(result).to.be.ok
        expect(@mailerSpies[1].calledOnce).to.be.true
        expect(@mailerSpies[1].firstCall.args[0]._id).to.deep.equal(@onlyBroadcast._id)
        done()

  it "will thank an account for peer minutes if they have used peer minutes", (done)->
    notifyAccountsThreeDaysAfterSigningUp (err, results)=>
      expect(err).to.be.null
      AccountEmailHistory.findOne _account: @onlyPeer._id, (err, aeh)=>
        expect(err).to.be.null
        expect(aeh).to.be.ok
        result = aeh.findKind('threeDayNotification')
        expect(result).to.be.ok
        expect(@mailerSpies[2].calledOnce).to.be.true
        expect(@mailerSpies[2].firstCall.args[0]._id).to.deep.equal(@onlyPeer._id)
        done()
