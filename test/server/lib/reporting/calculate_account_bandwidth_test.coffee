Account = Cine.server_model('account')
Project = Cine.server_model('project')
EdgecastStream = Cine.server_model('edgecast_stream')
StreamUsageReport = Cine.server_model('stream_usage_report')
CalculateAccountBandwidth = Cine.server_lib('reporting/calculate_account_bandwidth')

describe 'CalculateAccountBandwidth', ->

  beforeEach (done)->
    @account = new Account(billingProvider: 'cine.io', name: 'dat account', plans: ['basic'])
    @account.save done
  beforeEach (done)->
    @project1 = new Project(name: 'project1', _account: @account._id)
    @project1.save done
  beforeEach (done)->
    @project2 = new Project(name: 'project2', _account: @account._id)
    @project2.save done
  beforeEach (done)->
    @notOwnedProject = new Project(name: 'notOwnedProject')
    @notOwnedProject.save done
  beforeEach (done)->
    @stream1 = new EdgecastStream(_project: @project1._id)
    @stream1.save done
  beforeEach (done)->
    @stream2 = new EdgecastStream(_project: @project1._id)
    @stream2.save done
  beforeEach (done)->
    @stream3 = new EdgecastStream(_project: @project2._id)
    @stream3.save done
  beforeEach (done)->
    @stream4 = new EdgecastStream(_project: @project2._id)
    @stream4.save done
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
    createReportForStream @stream3, @thisMonth, @lastMonth, done
  beforeEach (done)->
    createReportForStream @stream4, @thisMonth, @lastMonth, done
  beforeEach (done)->
    createReportForStream @notProjectStream, @thisMonth, @lastMonth, done

  describe '#byMonth', ->

    it 'can aggrigate for this month', (done)->
      CalculateAccountBandwidth.byMonth @account, @thisMonth, (err, monthlyBytes)->
        expect(err).to.be.undefined
        expect(monthlyBytes).to.equal(31376164)
        done()

    it 'can aggrigate by last month', (done)->
      CalculateAccountBandwidth.byMonth @account, @lastMonth, (err, monthlyBytes)->
        expect(err).to.be.undefined
        expect(monthlyBytes).to.equal(12172316)
        done()

    it 'can aggrigate by two months ago', (done)->
      CalculateAccountBandwidth.byMonth @account, @twoMonthsAgo, (err, monthlyBytes)->
        expect(err).to.be.undefined
        expect(monthlyBytes).to.equal(0)
        done()

  describe '#total', ->

    it 'can aggrigate all account projects', (done)->
      CalculateAccountBandwidth.total @account, (err, monthlyBytes)->
        expect(err).to.be.undefined
        expect(monthlyBytes).to.equal(43548480)
        done()
