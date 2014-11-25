Project = Cine.server_model('project')
EdgecastStream = Cine.server_model('edgecast_stream')
StreamUsageReport = Cine.server_model('stream_usage_report')
CalculateProjectBandwidth = Cine.server_lib('reporting/calculate_project_bandwidth')

describe 'CalculateProjectBandwidth', ->

  beforeEach (done)->
    @project = new Project(name: 'the project')
    @project.save done
  beforeEach (done)->
    @stream1 = new EdgecastStream(_project: @project._id)
    @stream1.save done
  beforeEach (done)->
    @stream2 = new EdgecastStream(_project: @project._id)
    @stream2.save done
  beforeEach (done)->
    @notProjectStream = new EdgecastStream()
    @notProjectStream.save done

  addReportEntries = (report, thisMonth, lastMonth)->
    report.logEntries.push
      bytes: 169034
      entryDate: thisMonth
      duration: 47
      kind: 'fms'

    report.logEntries.push
      bytes: 3043079
      entryDate: lastMonth
      duration: 834
      kind: 'fms'

    report.logEntries.push
      bytes: 7675007
      entryDate: thisMonth
      duration: 250
      kind: 'fms'

  createReportForStream = (stream, thisMonth, lastMonth, done)->
    report = new StreamUsageReport(_edgecastStream: stream)
    addReportEntries(report, thisMonth, lastMonth)
    report.save done

  beforeEach ->
    @thisMonth = new Date
    @lastMonth = new Date
    @lastMonth.setDate(1)
    @lastMonth.setMonth(@lastMonth.getMonth() - 1)
    @twoMonthsAgo = new Date
    @twoMonthsAgo.setDate(1)
    @twoMonthsAgo.setMonth(@twoMonthsAgo.getMonth() - 2)

  beforeEach (done)->
    createReportForStream @stream1, @thisMonth, @lastMonth, done
  beforeEach (done)->
    createReportForStream @stream2, @thisMonth, @lastMonth, done
  beforeEach (done)->
    createReportForStream @notProjectStream, @thisMonth, @lastMonth, done

  describe '#byMonth', ->

    it 'can aggrigate for this month', (done)->
      CalculateProjectBandwidth.byMonth @project._id, @thisMonth, (err, monthlyBytes)->
        expect(err).to.be.null
        expect(monthlyBytes).to.equal(15688082)
        done()

    it 'can aggrigate by last month', (done)->
      CalculateProjectBandwidth.byMonth @project._id, @lastMonth, (err, monthlyBytes)->
        expect(err).to.be.null
        expect(monthlyBytes).to.equal(6086158)
        done()

    it 'can aggrigate by two months ago', (done)->
      CalculateProjectBandwidth.byMonth @project._id, @twoMonthsAgo, (err, monthlyBytes)->
        expect(err).to.be.null
        expect(monthlyBytes).to.equal(0)
        done()

  describe '#total', ->

    it 'will aggregate all project streams', (done)->
      CalculateProjectBandwidth.total @project._id, (err, monthlyBytes)->
        expect(err).to.be.null
        expect(monthlyBytes).to.equal(21774240)
        done()
