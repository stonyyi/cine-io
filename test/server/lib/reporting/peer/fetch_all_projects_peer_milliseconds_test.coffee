fetchAllProjectsPeerMillisecondsFromKeen = Cine.server_lib('reporting/peer/fetch_all_projects_peer_milliseconds')

describe "fetchAllProjectsPeerMillisecondsFromKeen", ->
  beforeEach ->
    @month = new Date("February 5 2015")
  beforeEach ->
    @keenNock = requireFixture('nock/keen/sum_peer_milliseconds_group_by_project')()

  it 'returns the sum of all projects peer milliseconds grouped by projectId', (done)->
    fetchAllProjectsPeerMillisecondsFromKeen @month, (err, response)->
      expect(err).to.be.null
      expected =
        '54adafdbaf652c8cb8624821': 396963687

      expect(response).to.deep.equal(expected)
      done()
