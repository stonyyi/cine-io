fs = require('fs')
_ = require('underscore')
copyFile = Cine.require('test/helpers/copy_file')
gzipFile = Cine.require('test/helpers/gzip_file')
ParsedLog = Cine.server_model('parsed_log')
downloadAndParseCloudfrontLogs = Cine.server_lib('reporting/download_and_parse_cloudfront_logs')
FakeFtpClient = Cine.require('test/helpers/fake_ftp_client')
EdgecastStream = Cine.server_model('edgecast_stream')
StreamUsageReport = Cine.server_model('stream_usage_report')
s3Client = Cine.server_lib('aws/s3_client')

describe 'downloadAndParseCloudfrontLogs', ->

  beforeEach ->
    @s3Nock1 = requireFixture('nock/aws/list_hls_folders_success')()
    @s3Nock2 = requireFixture('nock/aws/list_hls_files_success')()
    @s3Nock3 = requireFixture('nock/aws/list_vod_files_success')()

  beforeEach ->
    @hlsLogName = "hls/publish-sfo1/EBXGNCBDF3ULO.2014-11-24-19.b5342c87.gz"
    @vodLogName = "vod/E1MQZCUJMYYB8J.2014-11-24-01.f400acf3.gz"
    @hlsOutputPath = Cine.path("tmp/cloudfront_logs/EBXGNCBDF3ULO.2014-11-24-19.b5342c87.gz")
    @vodOutputPath = Cine.path("tmp/cloudfront_logs/E1MQZCUJMYYB8J.2014-11-24-01.f400acf3.gz")
    @downloadStub = sinon.stub s3Client, 'downloadFile', (localPath, LOG_BUCKET, file, callback)=>
      expect(LOG_BUCKET).to.equal("cine-cloudfront-logging")
      if file == @hlsLogName
        expect(localPath).to.equal(@hlsOutputPath)
        gzipFile.createNewFile Cine.path("test/fixtures/cloudfront_logs/hls_example.log"), @hlsOutputPath, callback
      else
        expect(localPath).to.equal(@vodOutputPath)
        gzipFile.createNewFile Cine.path("test/fixtures/cloudfront_logs/vod_example.log"), @vodOutputPath, callback

  afterEach ->
    @downloadStub.restore()

  describe 'success', ->

    beforeEach (done)->
      @stream = new EdgecastStream(streamName: 'bkcFcqG0V')
      @stream.save done

    it 'downloads and parses cloudfront logs', (done)->
      downloadAndParseCloudfrontLogs (err)=>
        expect(err).to.be.undefined
        expect(@s3Nock1.isDone()).to.be.true
        expect(@s3Nock2.isDone()).to.be.true
        expect(@s3Nock3.isDone()).to.be.true
        ParsedLog.find (err, parsedLogs)=>
          expect(parsedLogs).to.have.length(2)
          console.log(parsedLogs)
          parsedLog = _.findWhere parsedLogs, logName: "hls/publish-sfo1/EBXGNCBDF3ULO.2014-11-24-19.b5342c87.gz"
          expect(parsedLog.hasStarted).to.be.true
          expect(parsedLog.source).to.equal('cloudfront')
          expect(parsedLog.parseError).to.be.undefined
          expect(parsedLog.isComplete).to.be.true

          parsedLog = _.findWhere parsedLogs, logName: "vod/E1MQZCUJMYYB8J.2014-11-24-01.f400acf3.gz"
          expect(parsedLog.hasStarted).to.be.true
          expect(parsedLog.source).to.equal('cloudfront')
          expect(parsedLog.parseError).to.be.undefined
          expect(parsedLog.isComplete).to.be.true

          StreamUsageReport.findOne _edgecastStream: @stream._id, (err, report)->
            expect(err).to.be.null
            expect(report.logEntries).to.have.length(8)
            entry = report.logEntries[0]
            expect(entry.entryDate.toString()).to.equal(new Date('Nov 24 2014 19:26:35').toString())
            expect(entry.bytes).to.equal(680099)
            expect(entry.kind).to.equal('hls')
            entry = report.logEntries[5]
            expect(entry.entryDate.toString()).to.equal(new Date('Nov 24 2014 01:48:41').toString())
            expect(entry.bytes).to.equal(689)
            expect(entry.kind).to.equal('vod')
            done()

  describe "double processing logs", ->
    beforeEach (done)->
      parsedLog = new ParsedLog(hasStarted: true, logName: @hlsLogName)
      parsedLog.save done

    beforeEach (done)->
      parsedLog = new ParsedLog(hasStarted: true, logName: @vodLogName)
      parsedLog.save done

    it 'does not double process logs', (done)->
      downloadAndParseCloudfrontLogs (err)->
        expect(err).to.be.undefined
        ParsedLog.find (err, parsedLogs)->
          expect(parsedLogs).to.have.length(2)

          StreamUsageReport.find (err, reports)->
            expect(err).to.be.null
            expect(reports).to.have.length(0)
            done()

  describe 'stream not found', ->
    afterEach (done)->
      fs.unlink Cine.path("tmp/cloudfront_logs/EBXGNCBDF3ULO.2014-11-24-19.b5342c87"), done
    afterEach (done)->
      fs.unlink Cine.path("tmp/cloudfront_logs/E1MQZCUJMYYB8J.2014-11-24-01.f400acf3"), done

    it 'will save process errors', (done)->
      downloadAndParseCloudfrontLogs (err)->
        expect(err).to.be.undefined
        ParsedLog.find (err, parsedLogs)->
          expect(parsedLogs).to.have.length(2)
          # hls
          parsedLog = parsedLog = _.findWhere parsedLogs, logName: "hls/publish-sfo1/EBXGNCBDF3ULO.2014-11-24-19.b5342c87.gz"
          expect(parsedLog.hasStarted).to.be.true
          expect(parsedLog.parseErrors).to.have.length(5)
          firstError = parsedLog.parseErrors[0]
          secondError = parsedLog.parseErrors[1]
          expect(_.keys(firstError).sort()).to.deep.equal(["data", "error", "rowNumber"])
          expect(firstError.error).to.equal("could not find stream: bkcFcqG0V")
          expect(firstError.rowNumber).to.equal(2)
          expect(secondError.error).to.equal("could not find stream: bkcFcqG0V")
          expect(secondError.rowNumber).to.equal(3)
          expect(parsedLog.isComplete).to.be.true

          # vod
          parsedLog = _.findWhere parsedLogs, logName: "vod/E1MQZCUJMYYB8J.2014-11-24-01.f400acf3.gz"
          expect(parsedLog.hasStarted).to.be.true
          expect(parsedLog.parseErrors).to.have.length(3)
          firstError = parsedLog.parseErrors[0]
          secondError = parsedLog.parseErrors[1]
          expect(_.keys(firstError).sort()).to.deep.equal(["data", "error", "rowNumber"])
          expect(firstError.error).to.equal("could not find stream: bkcFcqG0V")
          expect(firstError.rowNumber).to.equal(2)
          expect(secondError.error).to.equal("could not find stream: bkcFcqG0V")
          expect(secondError.rowNumber).to.equal(3)
          expect(parsedLog.isComplete).to.be.true
          done()
