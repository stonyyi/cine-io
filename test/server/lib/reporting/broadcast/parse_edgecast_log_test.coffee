parseEdgecastLog = Cine.server_lib('reporting/broadcast/parse_edgecast_log')
StreamUsageReport = Cine.server_model('stream_usage_report')
EdgecastStream = Cine.server_model('edgecast_stream')
_ = require('underscore')

describe 'parseEdgecastLog', ->

  createBothStreams = ->
    beforeEach (done)->
      @stream = new EdgecastStream(instanceName: 'i-name', streamName: 'sName')
      @stream.save done

    beforeEach (done)->
      @stream2 = new EdgecastStream(instanceName: 'i-name2', streamName: 'sName2')
      @stream2.save done

  describe 'fms', ->
    beforeEach ->
      @fileLocation = Cine.path("test/fixtures/edgecast_logs/fms_example.log")

    it 'errors when there is a log entry that points to a stream we do not know about', (done)->
      parseEdgecastLog @fileLocation, (err)->
        expect(err).to.have.length(2)
        firstError = err[0]
        secondError = err[1]
        expect(_.keys(firstError).sort()).to.deep.equal(["data", "error", "rowNumber"])
        expect(firstError.error).to.equal("could not find stream: i-name, sName")
        expect(firstError.rowNumber).to.equal(0)
        expect(secondError.error).to.equal("could not find stream: i-name2, sName2")
        expect(secondError.rowNumber).to.equal(1)
        StreamUsageReport.count (err, count)->
          expect(err).to.be.null
          expect(count).to.equal(0)
          done()


    describe 'success', ->
      createBothStreams()

      it 'creates an StreamUsageReport when one is not found', (done)->
        parseEdgecastLog @fileLocation, (err)=>
          expect(err).to.be.undefined
          StreamUsageReport.findOne _edgecastStream: @stream._id, (err, report)->
            expect(err).to.be.null
            expect(report.logEntries).to.have.length(1)
            entry = report.logEntries[0]
            expect(entry.entryDate.toString()).to.equal(new Date('May 14 2014 04:17:00').toString())
            expect(entry.duration).to.equal(26)
            expect(entry.bytes).to.equal(3965)
            expect(entry.kind).to.equal('fms')
            done()

      it 'appends to an existing StreamUsageReport', (done)->
        initialReport = new StreamUsageReport(_edgecastStream: @stream._id)
        initialReport.logEntries.push
          entryDate: new Date
          duration: 12345
          bytes: 9876
          kind: 'fms'
        initialReport.save (err)=>
          expect(err).to.be.null
          parseEdgecastLog @fileLocation, (err)=>
            expect(err).to.be.undefined
            StreamUsageReport.findOne _edgecastStream: @stream._id, (err, report)->
              expect(report.logEntries).to.have.length(2)
              entry = report.logEntries[1]
              expect(entry.entryDate.toString()).to.equal(new Date('May 14 2014 04:17:00').toString())
              expect(entry.duration).to.equal(26)
              expect(entry.bytes).to.equal(3965)
              expect(entry.kind).to.equal('fms')
              done()

  describe 'hls', ->
    beforeEach ->
      @fileLocation = Cine.path("test/fixtures/edgecast_logs/wpc_example.log")

    it 'errors when there is a log entry that points to a stream we do not know about', (done)->
      parseEdgecastLog @fileLocation, (err)->
        expect(err).to.have.length(1)
        firstError = err[0]
        expect(_.keys(firstError).sort()).to.deep.equal(["data", "error", "rowNumber"])
        expect(firstError.error).to.equal("could not find stream: i-name, sName")
        expect(firstError.rowNumber).to.equal(1)
        StreamUsageReport.count (err, count)->
          expect(err).to.be.null
          expect(count).to.equal(0)
          done()

    describe 'success', ->
      createBothStreams()

      it 'creates an StreamUsageReport when one is not found', (done)->
        parseEdgecastLog @fileLocation, (err)=>
          expect(err).to.be.undefined
          StreamUsageReport.findOne _edgecastStream: @stream._id, (err, report)->
            expect(err).to.be.null
            expect(report.logEntries).to.have.length(1)
            entry = report.logEntries[0]
            expect(entry.entryDate.toString()).to.equal(new Date('May 18 2014 06:55:07').toString())
            expect(entry.bytes).to.equal(2256659)
            expect(entry.kind).to.equal('hls')
            done()

      it 'appends to an existing StreamUsageReport', (done)->
        initialReport = new StreamUsageReport(_edgecastStream: @stream._id)
        initialReport.logEntries.push
          entryDate: new Date
          duration: 12345
          bytes: 9876
          kind: 'fms'
        initialReport.save (err)=>
          expect(err).to.be.null
          parseEdgecastLog @fileLocation, (err)=>
            expect(err).to.be.undefined
            StreamUsageReport.findOne _edgecastStream: @stream._id, (err, report)->
              expect(report.logEntries).to.have.length(2)
              entry = report.logEntries[1]
              expect(entry.entryDate.toString()).to.equal(new Date('May 18 2014 06:55:07').toString())
              expect(entry.bytes).to.equal(2256659)
              expect(entry.kind).to.equal('hls')
              done()
