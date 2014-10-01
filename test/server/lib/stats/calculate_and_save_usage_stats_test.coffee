calculateAndSaveUsageStats = Cine.server_lib("stats/calculate_and_save_usage_stats")
calculateUsageStats = Cine.server_lib("stats/calculate_usage_stats")
Stats = Cine.server_lib("stats")

describe 'calculateAndSaveUsageStats', ->
  beforeEach ->
    @calculateStub = sinon.stub calculateUsageStats, 'byMonth', (month, callback)->
      callback(null, the: "full usage stats")

  afterEach ->
    @calculateStub.restore()

  it 'calculates stats and saves them', (done)->
    calculateAndSaveUsageStats (err)->
      expect(err).to.be.null
      Stats.getUsage (err, results)->
        expect(err).to.be.null
        expect(results).to.deep.equal(the: 'full usage stats')
        done()
