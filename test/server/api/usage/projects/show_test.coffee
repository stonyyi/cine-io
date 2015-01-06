Project = Cine.server_model('project')
ShowUsageReportsProject = testApi Cine.api('usage/projects/show')
CalculateProjectBandwidth = Cine.server_lib('reporting/broadcast/calculate_project_bandwidth')
CalculateProjectStorage = Cine.server_lib('reporting/storage/calculate_project_storage')

describe 'UsageReports/Projects#Show', ->
  testApi.requresApiKey ShowUsageReportsProject, 'secret'

  beforeEach (done)->
    @project = new Project secretKey: "dat secret key"
    @project.save done

  beforeEach ->
    @thisMonth = new Date
    @lastMonth = new Date
    @lastMonth.setDate(1)
    @lastMonth.setMonth(@lastMonth.getMonth() - 1)
    @twoMonthsAgo = new Date
    @twoMonthsAgo.setDate(1)
    @twoMonthsAgo.setMonth(@twoMonthsAgo.getMonth() - 2)

  monthIsLastMonth = (monthNumber, nowMonthNumber)->
    (monthNumber == nowMonthNumber - 1) || checkForYearRollover(monthNumber, nowMonthNumber, 11)

  monthIsTwoMonthsAgo = (monthNumber, nowMonthNumber)->
    (monthNumber == nowMonthNumber - 2) || checkForYearRollover(monthNumber, nowMonthNumber, 10)

  checkForYearRollover = (monthNumber, nowMonthNumber, monthToCheck)->
    monthNumber == monthToCheck && nowMonthNumber == 0

  beforeEach ->
    today = new Date
    today.setDate(1)
    @bandwidthStub = sinon.stub CalculateProjectBandwidth, 'byMonth', (project, date, callback)->
      if date.getMonth() == today.getMonth()
        callback(null, 123)
      else if monthIsLastMonth(date.getMonth(), today.getMonth())
        callback(null, 456)
      else if monthIsTwoMonthsAgo(date.getMonth(), today.getMonth())
        callback(null, 789)
      else
        throw new Error("requesting longer date")

  afterEach ->
    @bandwidthStub.restore()

  beforeEach ->
    today = new Date
    today.setDate(1)
    @storageStub = sinon.stub CalculateProjectStorage, 'byMonth', (project, date, callback)->
      if date.getMonth() == today.getMonth()
        callback(null, 777)
      else if monthIsLastMonth(date.getMonth(), today.getMonth())
        callback(null, 888)
      else if monthIsTwoMonthsAgo(date.getMonth(), today.getMonth())
        callback(null, 999)
      else
        throw new Error("requesting longer date")

  afterEach ->
    @storageStub.restore()

  it 'requires a valid month', (done)->
    params = {secretKey: 'dat secret key'}
    callback = (err, response, options)->
      expect(err).to.contain('month parameter required')
      expect(response).to.be.null
      expect(options.status).to.equal(400)
      done()

    ShowUsageReportsProject params, callback

  it 'requires a valid month', (done)->
    params = {secretKey: 'dat secret key', month: 'NOT VALID MONTH'}
    callback = (err, response, options)->
      expect(err).to.contain('invalid month')
      expect(response).to.be.null
      expect(options.status).to.equal(400)
      done()

    ShowUsageReportsProject params, callback

  it 'returns no values if there are no reports requested', (done)->
    params = {secretKey: 'dat secret key', month: @twoMonthsAgo.toISOString()}
    callback = (err, response)=>
      expect(err).to.be.null
      expectedResponse =
        secretKey: 'dat secret key'
        month: @twoMonthsAgo.toISOString()
      expect(response).to.deep.equal(expectedResponse)
      done()

    ShowUsageReportsProject params, callback

  it 'calculates a usage report for a passed in month', (done)->
    params = {secretKey: 'dat secret key', month: @twoMonthsAgo.toISOString(), report: ['bandwidth', 'storage']}
    callback = (err, response)=>
      expect(err).to.be.null
      expectedResponse =
        bandwidth: 789
        storage: 999
        secretKey: 'dat secret key'
        month: @twoMonthsAgo.toISOString()
      expect(response).to.deep.equal(expectedResponse)
      done()

    ShowUsageReportsProject params, callback
