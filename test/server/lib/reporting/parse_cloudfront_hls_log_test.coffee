processCloudfrontHlsLog = Cine.server_lib('reporting/parse_cloudfront_hls_log')

EdgecastStreamReport = Cine.server_model('edgecast_stream_report')
EdgecastStream = Cine.server_model('edgecast_stream')
_ = require('underscore')

describe 'processCloudfrontHlsLog', ->

  describe 'hls', ->
    beforeEach ->
      @fileLocation = Cine.path("test/fixtures/cloudfront_logs/hls_example.log")

    it 'errors when there is a log entry that points to a stream we do not know about', (done)->
      processCloudfrontHlsLog @fileLocation, (err)->
        expect(err).to.have.length(5)
        firstError = err[0]
        expect(_.keys(firstError).sort()).to.deep.equal(["data", "error", "rowNumber"])
        expect(firstError.error).to.equal("could not find stream: bkcFcqG0V")
        expect(firstError.rowNumber).to.equal(2)
        EdgecastStreamReport.count (err, count)->
          expect(err).to.be.null
          expect(count).to.equal(0)
          done()

    describe 'success', ->
      beforeEach (done)->
        @stream = new EdgecastStream(streamName: 'bkcFcqG0V')
        @stream.save done

      it 'creates an EdgecastStreamReport when one is not found', (done)->
        processCloudfrontHlsLog @fileLocation, (err)=>
          expect(err).to.be.undefined
          EdgecastStreamReport.findOne _edgecastStream: @stream._id, (err, report)->
            expect(err).to.be.null
            expect(report.logEntries).to.have.length(5)
            entry = report.logEntries[0]
            expect(entry.entryDate.toString()).to.equal(new Date('Nov 24 2014 19:26:35').toString())
            expect(entry.bytes).to.equal(680099)
            expect(entry.kind).to.equal('hls')
            done()

      it 'appends to an existing EdgecastStreamReport', (done)->
        initialReport = new EdgecastStreamReport(_edgecastStream: @stream._id)
        initialReport.logEntries.push
          entryDate: new Date
          duration: 12345
          bytes: 9876
          kind: 'fms'
        initialReport.save (err)=>
          expect(err).to.be.null
          processCloudfrontHlsLog @fileLocation, (err)=>
            expect(err).to.be.undefined
            EdgecastStreamReport.findOne _edgecastStream: @stream._id, (err, report)->
              expect(report.logEntries).to.have.length(6)
              entry = report.logEntries[1]
              expect(entry.entryDate.toString()).to.equal(new Date('Nov 24 2014 19:26:35').toString())
              expect(entry.bytes).to.equal(680099)
              expect(entry.kind).to.equal('hls')
              done()
