spawn = require('child_process').spawn
fs = require('fs')
copyFile = Cine.require('test/helpers/copy_file')
unzipAndProcessEdgecastLog = Cine.server_lib('reporting/unzip_and_process_edgecast_log')
EdgecastStreamReport = Cine.server_model('edgecast_stream_report')
EdgecastStream = Cine.server_model('edgecast_stream')

describe 'unzipAndProcessEdgecastLog', ->

  beforeEach ->
    @originalFileName = Cine.path "test/fixtures/edgecast_logs/fms_example.log"

  beforeEach (done)->
    @gzExampleFile = Cine.path "test/fixtures/edgecast_logs/fms_gz_example.log"
    copyFile @originalFileName, @gzExampleFile, done

  beforeEach (done)->
    @gzippedFileName = "#{@gzExampleFile}.gz"
    console.log("Filenames", @gzippedFileName, @gzExampleFile)
    gzipProcess = spawn 'gzip', ["-c", @gzExampleFile]
    logStream = fs.createWriteStream(@gzippedFileName, {flags: 'w'})
    gzipProcess.stdout.pipe(logStream)
    gzipProcess.stderr.pipe(logStream)
    gzipProcess.on 'close', (code)->
      expect(code).to.equal(0)
      done()

  beforeEach (done)->
    fs.exists @gzippedFileName, (exists)->
      expect(exists).to.be.true
      done()

  beforeEach (done)->
    @stream = new EdgecastStream(instanceName: 'i-name', streamName: 'sName')
    @stream.save done

  it 'unzips a file, runs it through parseEdgecastLog, then deletes the file', (done)->
    unzipAndProcessEdgecastLog @gzippedFileName, (err)=>
      expect(err).to.be.undefined
      EdgecastStreamReport.findOne _edgecastStream: @stream._id, (err, report)=>
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
