User = Cine.server_model('user')
Project = Cine.server_model('project')
EdgecastStream = Cine.server_model('edgecast_stream')
EdgecastStreamReport = Cine.server_model('edgecast_stream_report')
CalculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')

describe 'CalculateAccountUsage', ->

  beforeEach (done)->
    @project1 = new Project(name: 'project1')
    @project1.save done
  beforeEach (done)->
    @project2 = new Project(name: 'project2')
    @project2.save done
  beforeEach (done)->
    @notOwnedProject = new Project(name: 'notOwnedProject')
    @notOwnedProject.save done
  beforeEach (done)->
    @user = new User(name: 'project owner', plan: 'startup')
    @user.permissions.push objectId: @project1._id, objectName: "Project"
    @user.permissions.push objectId: @project2._id, objectName: "Project"
    @user.save done
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
    report = new EdgecastStreamReport(_edgecastStream: stream)
    addReportEntries(report, thisMonth, lastMonth)
    report.save done

  beforeEach ->
    @thisMonth = new Date
    @lastMonth = new Date
    @lastMonth.setMonth(@lastMonth.getMonth() - 1)
    @twoMonthsAgo = new Date
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
      CalculateAccountUsage.byMonth @user, @thisMonth, (err, monthlyBytes)->
        expect(err).to.be.undefined
        expect(monthlyBytes).to.equal(31376164)
        done()

    it 'can aggrigate by last month', (done)->
      CalculateAccountUsage.byMonth @user, @lastMonth, (err, monthlyBytes)->
        expect(err).to.be.undefined
        expect(monthlyBytes).to.equal(12172316)
        done()

    it 'can aggrigate by two months ago', (done)->
      CalculateAccountUsage.byMonth @user, @twoMonthsAgo, (err, monthlyBytes)->
        expect(err).to.be.undefined
        expect(monthlyBytes).to.equal(0)
        done()
