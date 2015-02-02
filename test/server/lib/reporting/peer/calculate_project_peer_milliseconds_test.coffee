Project = Cine.server_model('project')
calculateProjectPeerMilliseconds = Cine.server_lib('reporting/peer/calculate_project_peer_milliseconds')

describe 'calculateProjectPeerMilliseconds', ->
  beforeEach (done)->
    @project = new Project
    @project.save done

  beforeEach ->
    @month = new Date

  describe 'thisMonth', ->

    beforeEach ->
      @nock = requireFixture('nock/keen/results_for_project')(@project._id, @month)

    it 'fetches and parses events for this month', (done)->
      calculateProjectPeerMilliseconds.thisMonth @project._id, (err, totalTimeInMs)=>
        expect(err).to.be.null
        expect(totalTimeInMs).to.equal(94061)
        expect(@nock.isDone()).to.be.true
        done()

  describe 'byMonth', ->
    beforeEach ->
      @month.setMonth(@month.getMonth() - 1)

    beforeEach ->
      @nock = requireFixture('nock/keen/results_for_project')(@project._id, @month)

    it 'fetches and parses events for this month', (done)->
      calculateProjectPeerMilliseconds.byMonth @project._id, @month, (err, totalTimeInMs)=>
        expect(err).to.be.null
        expect(totalTimeInMs).to.equal(94061)
        expect(@nock.isDone()).to.be.true
        done()
