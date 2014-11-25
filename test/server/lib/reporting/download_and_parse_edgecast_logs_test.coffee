_ = require('underscore')
ParsedLog = Cine.server_model('parsed_log')
downloadAndParseEdgecastLogs = Cine.server_lib('reporting/download_and_parse_edgecast_logs')
FakeFtpClient = Cine.require('test/helpers/fake_ftp_client')
EdgecastStream = Cine.server_model('edgecast_stream')
StreamUsageReport = Cine.server_model('stream_usage_report')

describe 'downloadAndParseEdgecastLogs', ->

  beforeEach ->
    @fakeFtpClient = new FakeFtpClient
    @listStub = @fakeFtpClient.stub('list')
    @logName = "fms_example_from_ftp.log.gz"
    @lists = [{name: @logName}]
    @listStub.callsArgWith 1, null, @lists

  afterEach ->
    @fakeFtpClient.restore()

  describe 'success', ->
    beforeEach (done)->
      @stream = new EdgecastStream(instanceName: 'i-name', streamName: 'sName')
      @stream.save done

    beforeEach (done)->
      @stream = new EdgecastStream(instanceName: 'i-name2', streamName: 'sName2')
      @stream.save done

    it 'downloads and parses edgecast logs', (done)->
      downloadAndParseEdgecastLogs (err)=>
        expect(@listStub.calledOnce).to.be.true
        expect(@listStub.firstCall.args[0]).to.equal('/logs')
        expect(err).to.be.undefined
        ParsedLog.find (err, parsedLogs)=>
          expect(parsedLogs).to.have.length(1)
          parsedLog = parsedLogs[0]
          expect(parsedLog.hasStarted).to.be.true
          expect(parsedLog.source).to.equal('edgecast')
          expect(parsedLog.parseError).to.be.undefined
          expect(parsedLog.isComplete).to.be.true

          StreamUsageReport.findOne _edgecastStream: @stream._id, (err, report)->
            expect(err).to.be.null
            expect(report.logEntries).to.have.length(1)
            entry = report.logEntries[0]
            expect(entry.entryDate.toString()).to.equal(new Date('May 14 2014 04:17:00').toString())
            expect(entry.duration).to.equal(26)
            expect(entry.bytes).to.equal(3965)
            expect(entry.kind).to.equal('fms')
            done()

  describe "double processing logs", ->
    beforeEach (done)->
      parsedLog = new ParsedLog(hasStarted: true, logName: @logName)
      parsedLog.save done

    it 'does not double process logs', (done)->
      downloadAndParseEdgecastLogs (err)->
        expect(err).to.be.undefined
        ParsedLog.find (err, parsedLogs)->
          expect(parsedLogs).to.have.length(1)

          StreamUsageReport.find (err, reports)->
            expect(err).to.be.null
            expect(reports).to.have.length(0)
            done()

  it 'will save process errors', (done)->
    downloadAndParseEdgecastLogs (err)=>
      expect(err).to.be.undefined
      expect(@fakeFtpClient.connectStub.calledOnce).to.be.true
      expect(@fakeFtpClient.connectStub.firstCall.args).to.deep.equal([host: "ftp.vny.C45E.edgecastcdn.net", user: 'fake-account', password: 'fake-password', connTimeout: 30000])
      ParsedLog.find (err, parsedLogs)->
        expect(parsedLogs).to.have.length(1)
        parsedLog = parsedLogs[0]
        expect(parsedLog.hasStarted).to.be.true
        expect(parsedLog.parseErrors).to.have.length(2)
        firstError = parsedLog.parseErrors[0]
        secondError = parsedLog.parseErrors[1]
        expect(_.keys(firstError).sort()).to.deep.equal(["data", "error", "rowNumber"])
        expect(firstError.error).to.equal("could not find stream: i-name, sName")
        expect(firstError.rowNumber).to.equal(0)
        expect(secondError.error).to.equal("could not find stream: i-name2, sName2")
        expect(secondError.rowNumber).to.equal(1)
        expect(parsedLog.isComplete).to.be.true
        done()
