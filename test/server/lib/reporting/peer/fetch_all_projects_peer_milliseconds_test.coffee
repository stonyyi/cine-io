fetchAllProjectsPeerMilliseconds = Cine.server_lib('reporting/peer/fetch_all_projects_peer_milliseconds')

describe "fetchAllProjectsPeerMilliseconds", ->
  beforeEach ->
    @month = new Date("February 5 2015")
  beforeEach (done)->
    response =
      [{"projectId": "54adafdbaf652c8cb8624821", "result": 396963687}]
    @keenNock = requireFixture('nock/keen/sum_peer_milliseconds_group_by_project')(response, @month, done)

  it 'returns the sum of all projects peer milliseconds grouped by projectId', (done)->
    fetchAllProjectsPeerMilliseconds @month, (err, response)->
      expect(err).to.be.null
      expected =
        '54adafdbaf652c8cb8624821': 396963687

      expect(response).to.deep.equal(expected)
      done()
