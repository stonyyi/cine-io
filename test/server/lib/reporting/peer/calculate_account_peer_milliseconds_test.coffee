Account = Cine.server_model('account')
Project = Cine.server_model('project')
calculateAccountPeerMlliseconds = Cine.server_lib('reporting/peer/calculate_account_peer_milliseconds')

describe 'calculateAccountPeerMlliseconds', ->
  beforeEach (done)->
    @account = new Account productPlans: {broadcast: ['free']}, billingProvider: 'cine.io'
    @account.save done

  beforeEach (done)->
    @project1 = new Project _account: @account._id
    @project1.save done
  beforeEach (done)->
    @project2 = new Project _account: @account._id
    @project2.save done
  beforeEach (done)->
    @project3 = new Project
    @project3.save done

  beforeEach ->
    @month = new Date

  describe 'byMonth', ->

    beforeEach ->
      @nock1 = requireFixture('nock/keen/results_for_project')(@project1._id, @month)
      @nock2 = requireFixture('nock/keen/results_for_project')(@project2._id, @month)
      @nock3 = requireFixture('nock/keen/results_for_project')(@project3._id, @month)

    it 'fetches and parses events for the month for each project', (done)->
      calculateAccountPeerMlliseconds.byMonth @account, @month, (err, totalTimeInMs)=>
        expect(err).to.be.undefined
        expect(totalTimeInMs).to.equal(94061 * 2)
        expect(@nock1.isDone()).to.be.true
        expect(@nock2.isDone()).to.be.true
        expect(@nock3.isDone()).to.be.false
        done()

  describe 'byMonthWithKeenMilliseconds', ->

    it 'fetches and parses events for the month for each project', (done)->
      keenResults = {}
      keenResults[@project1._id.toString()] = 111
      keenResults[@project2._id.toString()] = 222
      keenResults[@project3._id.toString()] = 555

      calculateAccountPeerMlliseconds.byMonthWithKeenMilliseconds @account, @month, keenResults, (err, totalTimeInMs)->
        expect(err).to.be.undefined
        expect(totalTimeInMs).to.equal(333)
        done()
