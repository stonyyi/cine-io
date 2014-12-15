spawn = require('child_process').spawn
fs = require('fs')
copyFile = Cine.require('test/helpers/copy_file')
gzipFile = Cine.require('test/helpers/gzip_file')
unzipAndProcessFile = Cine.server_lib('reporting/unzip_and_process_file')
StreamUsageReport = Cine.server_model('stream_usage_report')
EdgecastStream = Cine.server_model('edgecast_stream')
parseEdgecastLog = Cine.server_lib('reporting/broadcast/parse_edgecast_log')

describe 'unzipAndProcessFile', ->

  beforeEach ->
    @originalFileName = Cine.path "test/fixtures/edgecast_logs/fms_example.log"

  beforeEach (done)->
    @gzExampleFile = Cine.path "tmp/edgecast_logs/fms_example.log"
    copyFile @originalFileName, @gzExampleFile, done

  beforeEach (done)->
    @gzippedFileName = "#{@gzExampleFile}.gz"
    console.log("Filenames", @gzippedFileName, @gzExampleFile)
    gzipFile.replaceFile @gzExampleFile, done

  beforeEach (done)->
    fs.exists @gzippedFileName, (exists)->
      expect(exists).to.be.true
      done()

  beforeEach (done)->
    @stream = new EdgecastStream(instanceName: 'i-name', streamName: 'sName')
    @stream.save done

  beforeEach (done)->
    @stream = new EdgecastStream(instanceName: 'i-name2', streamName: 'sName2')
    @stream.save done

  it 'unzips a file, runs it through parseEdgecastLog, then deletes the file', (done)->
    unzipAndProcessFile @gzippedFileName, parseEdgecastLog, (err)=>
      expect(err).to.be.undefined
      StreamUsageReport.findOne _edgecastStream: @stream._id, (err, report)=>
        expect(err).to.be.null
        expect(report.logEntries).to.have.length(1)
        entry = report.logEntries[0]
        expect(entry.entryDate.toString()).to.equal(new Date('May 14 2014 04:17:00').toString())
        expect(entry.duration).to.equal(26)
        expect(entry.bytes).to.equal(3965)
        expect(entry.kind).to.equal('fms')
        fs.exists @gzExampleFile, (exists)=>
          expect(exists).to.be.false
          fs.exists @gzippedFileName, (exists)->
            expect(exists).to.be.false
            done()
