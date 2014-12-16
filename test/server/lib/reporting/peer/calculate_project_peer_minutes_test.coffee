Project = Cine.server_model('project')
calculateProjectPeerMinutes = Cine.server_lib('reporting/peer/calculate_project_peer_minutes')

describe 'calculateProjectPeerMinutes', ->
  beforeEach (done)->
    @project = new Project
    @project.save done

  beforeEach ->
    @month = new Date

  describe 'thisMonth', ->

    beforeEach ->
      @nock = requireFixture('nock/keen/results_for_project')(@project._id, @month)

    it 'fetches and parses events for this month', (done)->
      calculateProjectPeerMinutes.thisMonth @project._id, (err, totalTimeInMs)=>
        expect(err).to.be.null
        expect(totalTimeInMs).to.equal(36545549)
        expect(@nock.isDone()).to.be.true
        done()

  describe 'byMonth', ->
    beforeEach ->
      @month.setMonth(@month.getMonth() - 1)

    beforeEach ->
      @nock = requireFixture('nock/keen/results_for_project')(@project._id, @month)

    it 'fetches and parses events for this month', (done)->
      calculateProjectPeerMinutes.byMonth @project._id, @month, (err, totalTimeInMs)=>
        expect(err).to.be.null
        expect(totalTimeInMs).to.equal(36545549)
        expect(@nock.isDone()).to.be.true
        done()
