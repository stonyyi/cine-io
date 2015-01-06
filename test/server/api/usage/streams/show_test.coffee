Project = Cine.server_model('project')
ShowUsageReportsStream = testApi Cine.api('usage/streams/show')
EdgecastStream = Cine.server_model('edgecast_stream')
StreamUsageReport = Cine.server_model('stream_usage_report')
StreamRecordings = Cine.server_model('stream_recordings')

describe 'UsageReports/Streams#Show', ->
  testApi.requresApiKey ShowUsageReportsStream, 'secret'

  beforeEach (done)->
    @project = new Project(secretKey: "dat secret key", name: 'the project')
    @project.save done
  beforeEach (done)->
    @stream1 = new EdgecastStream(_project: @project._id)
    @stream1.save done
  beforeEach (done)->
    @stream2 = new EdgecastStream(_project: @project._id)
    @stream2.save done

  beforeEach (done)->
    @stream3 = new EdgecastStream
    @stream3.save done

  beforeEach ->
    @thisMonth = new Date
    @lastMonth = new Date
    @lastMonth.setDate(1)
    @lastMonth.setMonth(@lastMonth.getMonth() - 1)
    @twoMonthsAgo = new Date
    @twoMonthsAgo.setDate(1)
    @twoMonthsAgo.setMonth(@twoMonthsAgo.getMonth() - 2)

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

  addRecordings = (recording, thisMonth, lastMonth)->

    recording.recordings.push
      name: "abc"
      size: 3043079
      date: lastMonth

    recording.recordings.push
      name: "def"
      size: 7573983
      date: thisMonth

    recording.recordings.push
      name: "ghi"
      size: 93737
      date: lastMonth

  createRecordingsForStream = (stream, thisMonth, lastMonth, done)->
    recordings = new StreamRecordings(_edgecastStream: stream)
    addRecordings(recordings, thisMonth, lastMonth)
    recordings.save done


  beforeEach (done)->
    createReportForStream @stream1, @thisMonth, @lastMonth, done
  beforeEach (done)->
    createReportForStream @stream2, @thisMonth, @lastMonth, done
  beforeEach (done)->
    createReportForStream @notProjectStream, @thisMonth, @lastMonth, done

  beforeEach (done)->
    createRecordingsForStream @stream1, @thisMonth, @lastMonth, done
  beforeEach (done)->
    createRecordingsForStream @stream2, @thisMonth, @lastMonth, done
  beforeEach (done)->
    createRecordingsForStream @notProjectStream, @thisMonth, @lastMonth, done

  it 'requires an id', (done)->
    params = {secretKey: 'dat secret key'}
    callback = (err, response, options)->
      expect(err).to.contain('id parameter required')
      expect(response).to.be.null
      expect(options.status).to.equal(400)
      done()

    ShowUsageReportsStream params, callback

  it 'requires a month', (done)->
    params = {secretKey: 'dat secret key', id: 'some id'}
    callback = (err, response, options)->
      expect(err).to.contain('month parameter required')
      expect(response).to.be.null
      expect(options.status).to.equal(400)
      done()

    ShowUsageReportsStream params, callback

  it 'requires a valid month', (done)->
    params = {secretKey: 'dat secret key', id: @stream1._id, month: 'NOT VALID MONTH'}
    callback = (err, response, options)->
      expect(err).to.contain('invalid month')
      expect(response).to.be.null
      expect(options.status).to.equal(400)
      done()

    ShowUsageReportsStream params, callback


  it 'requires a stream owned by that project month', (done)->
    params = {secretKey: 'dat secret key', id: @stream3._id, month: @lastMonth.toISOString()}
    callback = (err, response, options)->
      expect(err).to.contain('stream not found')
      expect(response).to.be.null
      expect(options.status).to.equal(404)
      done()

    ShowUsageReportsStream params, callback

  it 'calculates a usage report for a passed in month', (done)->
    params = {secretKey: 'dat secret key', id: @stream1._id, month: @lastMonth.toISOString()}
    callback = (err, response)=>
      expect(err).to.be.null
      expectedResponse =
        bandwidth: 3043079
        storage: 3043079 + 93737
        secretKey: 'dat secret key'
        month: @lastMonth.toISOString()
        id: @stream1._id.toString()
      expect(response).to.deep.equal(expectedResponse)
      done()

    ShowUsageReportsStream params, callback
