fetchAllProjectsPeerMilliseconds = Cine.server_lib('reporting/peer/fetch_all_projects_peer_milliseconds')

describe "fetchAllProjectsPeerMilliseconds", ->
  describe 'byMonth', ->
    beforeEach ->
      @month = new Date("February 5 2015")

    beforeEach (done)->
      response =
        [{"projectId": "54adafdbaf652c8cb8624821", "result": 396963687}]

      firstSecondInMonth = new Date(@month.getFullYear(), @month.getMonth(), 1)
      lastSecondInMonth = new Date(@month.getFullYear(), @month.getMonth() + 1)
      lastSecondInMonth.setSeconds(-1)

      @keenNock = requireFixture('nock/keen/sum_peer_milliseconds_group_by_project')(response, firstSecondInMonth, lastSecondInMonth, done)
    it 'returns the sum of all projects peer milliseconds grouped by projectId', (done)->
      fetchAllProjectsPeerMilliseconds.byMonth @month, (err, response)->
        expect(err).to.be.null
        expected =
          '54adafdbaf652c8cb8624821': 396963687

        expect(response).to.deep.equal(expected)
        done()

  describe 'between', ->
    beforeEach ->
      @month = new Date("February 5 2015")

    beforeEach (done)->
      response =
        [{"projectId": "54adafdbaf652c8cb8624821", "result": 396963687}]

      @start = new Date(@month.getFullYear(), @month.getMonth(), 10)
      @end = new Date(@month.getFullYear(), @month.getMonth(), 12)

      @keenNock = requireFixture('nock/keen/sum_peer_milliseconds_group_by_project')(response, @start, @end, done)

    it 'returns the sum of all projects peer milliseconds grouped by projectId', (done)->
      fetchAllProjectsPeerMilliseconds.between @start, @end, (err, response)->
        expect(err).to.be.null
        expected =
          '54adafdbaf652c8cb8624821': 396963687

        expect(response).to.deep.equal(expected)
        done()
