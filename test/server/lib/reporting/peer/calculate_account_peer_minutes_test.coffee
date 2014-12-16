Account = Cine.server_model('account')
Project = Cine.server_model('project')
calculateAccountPeerMinutes = Cine.server_lib('reporting/peer/calculate_account_peer_minutes')
processKeenPeerEventsForProject = Cine.server_lib('reporting/peer/process_keen_peer_events_for_project')

describe 'calculateAccountPeerMinutes', ->
  beforeEach (done)->
    @account = new Account plans: ['free'], billingProvider: 'cine.io'
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
      calculateAccountPeerMinutes.byMonth @account, @month, (err, totalTimeInMs)=>
        expect(err).to.be.undefined
        expect(totalTimeInMs).to.equal(36545549 * 2)
        expect(@nock1.isDone()).to.be.true
        expect(@nock2.isDone()).to.be.true
        expect(@nock3.isDone()).to.be.false
        done()
