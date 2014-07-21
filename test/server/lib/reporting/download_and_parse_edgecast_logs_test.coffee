parseEdgecastLog = Cine.server_lib('reporting/unzip_and_process_edgecast_log')
EdgecastParsedLog = Cine.server_model('edgecast_parsed_log')
downloadAndParseEdgecastLogs = Cine.server_lib('reporting/download_and_parse_edgecast_logs')
FakeFtpClient = Cine.require('test/helpers/fake_ftp_client')
EdgecastStream = Cine.server_model('edgecast_stream')
EdgecastStreamReport = Cine.server_model('edgecast_stream_report')

describe 'downloadAndParseEdgecastLogs', ->

  beforeEach ->
    @fakeFtpClient = new FakeFtpClient
    @connectStub = sinon.stub @fakeFtpClient, 'connect'
    @listStub = sinon.stub @fakeFtpClient, 'list'
    @lists = [{name: 'fms_example_from_ftp.log.gz'}]
    @listStub.callsArgWith 1, null, @lists

  beforeEach ->
    @stub = sinon.stub downloadAndParseEdgecastLogs, 'ftpFactory'
    @stub.returns(@fakeFtpClient)

  afterEach ->
    @stub.restore()
    @connectStub.restore()

  # beforeEach ->
    # TODO: need to verify that this
    # is not called in currently pending test
    # @parseSpy = sinon.spy parseEdgecastLog

  describe 'success', ->
    beforeEach (done)->
      @stream = new EdgecastStream(instanceName: 'i-name', streamName: 'sName')
      @stream.save done

    it 'downloads and parses edgecast logs', (done)->
      process.nextTick =>
        @fakeFtpClient.trigger('ready')
      downloadAndParseEdgecastLogs (err)=>
        expect(err).to.be.undefined
        EdgecastStreamReport.findOne _edgecastStream: @stream._id, (err, report)->
          expect(err).to.be.null
          expect(report.logEntries).to.have.length(1)
          entry = report.logEntries[0]
          expect(entry.entryDate.toString()).to.equal(new Date('May 14 2014 04:17:00').toString())
          expect(entry.duration).to.equal(26)
          expect(entry.bytes).to.equal(3965)
          expect(entry.kind).to.equal('fms')
          # expect(@parseSpy.calledOnce).to.be.true
          done()

  it 'does not double process logs'
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
