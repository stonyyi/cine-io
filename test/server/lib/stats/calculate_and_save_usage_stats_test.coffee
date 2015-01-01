calculateAndSaveUsageStats = Cine.server_lib("stats/calculate_and_save_usage_stats")
calculateUsageStats = Cine.server_lib("stats/calculate_usage_stats")
Stats = Cine.server_lib("stats")

describe 'calculateAndSaveUsageStats', ->

  monthIsLastMonth = (monthNumber, nowMonthNumber)->
    (monthNumber == nowMonthNumber - 1) || checkForYearRollover(monthNumber, nowMonthNumber)

  checkForYearRollover = (monthNumber, nowMonthNumber)->
    monthNumber == 11 && nowMonthNumber == 0

  beforeEach ->
    now = new Date
    now.setDate(1)
    @calculateStub = sinon.stub calculateUsageStats, 'byMonth', (month, callback)->
      monthNumber = month.getMonth()
      nowMonthNumber = now.getMonth()
      if monthNumber == nowMonthNumber
        callback(null, the: "this month usage stats")
      else if monthIsLastMonth(monthNumber, nowMonthNumber)
        callback(null, the: "last month usage stats")
      else
        throw new Error("unknown month")

  afterEach ->
    @calculateStub.restore()

  describe 'thisMonth', ->
    it 'calculates stats and saves them', (done)->
      d = new Date
      calculateAndSaveUsageStats (err)->
        expect(err).to.be.null
        Stats.getUsage d, (err, results)->
          expect(err).to.be.null
          expect(results).to.deep.equal(the: 'this month usage stats')
          done()

  describe 'byMonth', ->
    it 'calculates stats and saves them', (done)->
      d = new Date
      d.setDate(1)
      d.setMonth(d.getMonth() - 1)
      calculateAndSaveUsageStats.byMonth d, (err)->
        expect(err).to.be.null
        Stats.getUsage d, (err, results)->
          expect(err).to.be.null
          expect(results).to.deep.equal(the: 'last month usage stats')
          done()
