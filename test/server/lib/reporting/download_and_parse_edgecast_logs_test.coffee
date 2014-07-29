parseEdgecastLog = Cine.server_lib('reporting/unzip_and_process_edgecast_log')
EdgecastParsedLog = Cine.server_model('edgecast_parsed_log')
downloadAndParseEdgecastLogs = Cine.server_lib('reporting/download_and_parse_edgecast_logs')
FakeFtpClient = Cine.require('test/helpers/fake_ftp_client')
EdgecastStream = Cine.server_model('edgecast_stream')
EdgecastStreamReport = Cine.server_model('edgecast_stream_report')
edgecastFtpClientFactory = Cine.server_lib('edgecast_ftp_client_factory')

describe 'downloadAndParseEdgecastLogs', ->

  beforeEach ->
    @fakeFtpClient = new FakeFtpClient
    @connectStub = sinon.stub @fakeFtpClient, 'connect'
    @listStub = sinon.stub @fakeFtpClient, 'list'
    @logName = "fms_example_from_ftp.log.gz"
    @lists = [{name: @logName}]
    @listStub.callsArgWith 1, null, @lists

  beforeEach ->
    @stub = sinon.stub edgecastFtpClientFactory, 'builder'
    @stub.returns(@fakeFtpClient)

  afterEach ->
    @stub.restore()
    @connectStub.restore()

  describe 'success', ->
    beforeEach (done)->
      @stream = new EdgecastStream(instanceName: 'i-name', streamName: 'sName')
      @stream.save done

    it 'downloads and parses edgecast logs', (done)->
      process.nextTick =>
        @fakeFtpClient.trigger('ready')
      downloadAndParseEdgecastLogs (err)=>
        expect(err).to.be.undefined
        EdgecastParsedLog.find (err, parsedLogs)=>
          expect(parsedLogs).to.have.length(1)
          parsedLog = parsedLogs[0]
          expect(parsedLog.hasStarted).to.be.true
          expect(parsedLog.parseError).to.be.undefined
          expect(parsedLog.isComplete).to.be.true

          EdgecastStreamReport.findOne _edgecastStream: @stream._id, (err, report)->
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
      parsedLog = new EdgecastParsedLog(hasStarted: true, logName: @logName)
      parsedLog.save done


    it 'does not double process logs', (done)->
      process.nextTick =>
        @fakeFtpClient.trigger('ready')
      downloadAndParseEdgecastLogs (err)->
        expect(err).to.be.undefined
        EdgecastParsedLog.find (err, parsedLogs)->
          expect(parsedLogs).to.have.length(1)

          EdgecastStreamReport.find (err, reports)->
            expect(err).to.be.null
            expect(reports).to.have.length(0)
            done()

  it 'will save a process error', (done)->
    process.nextTick =>
      @fakeFtpClient.trigger('ready')
    downloadAndParseEdgecastLogs (err)=>
      expect(err).to.be.undefined
      expect(@connectStub.calledOnce).to.be.true
      expect(@connectStub.firstCall.args).to.deep.equal([host: "ftp.vny.C45E.edgecastcdn.net", user: 'fake-account', password: 'fake-password'])
      EdgecastParsedLog.find (err, parsedLogs)->
        expect(parsedLogs).to.have.length(1)
        parsedLog = parsedLogs[0]
        expect(parsedLog.hasStarted).to.be.true
        expect(parsedLog.parseError).to.equal("could not find stream: i-name, sName")
        expect(parsedLog.isComplete).to.be.false
        done()
