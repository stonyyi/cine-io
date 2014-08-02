EdgecastStreamReport = Cine.server_model('edgecast_stream_report')
modelTimestamps = Cine.require('test/helpers/model_timestamps')

describe 'EdgecastStreamReport', ->
  modelTimestamps EdgecastStreamReport

  addReportEntries = (report, thisMonth, thisMonth2, lastMonth)->

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
      entryDate: thisMonth2
      duration: 250
      kind: 'fms'

  beforeEach (done)->
    @report = new EdgecastStreamReport
    @thisMonth = new Date
    @thisMonth2 = new Date
    if @thisMonth.getDate() == 1
      @thisMonth2.setDate(@thisMonth2.getDate() + 1)
    else
      @thisMonth2.setDate(@thisMonth2.getDate() - 1)

    @lastMonth = new Date
    @lastMonth.setMonth(@lastMonth.getMonth() - 1)
    @twoMonthsAgo = new Date
    @twoMonthsAgo.setMonth(@twoMonthsAgo.getMonth() - 2)
    addReportEntries(@report, @thisMonth, @thisMonth2, @lastMonth)
    @report.save done

  describe '#bytesForMonth', ->

    it 'can aggrigate by month', ->
      thisMonthBytes = @report.bytesForMonth(@thisMonth)
      expect(thisMonthBytes).to.equal(7844041)
      thisMonthBytes = @report.bytesForMonth(@lastMonth)
      expect(thisMonthBytes).to.equal(3043079)
      thisMonthBytes = @report.bytesForMonth(@twoMonthsAgo)
      expect(thisMonthBytes).to.equal(0)

  describe '#totalBytes', ->

    it 'can aggrigate all the entries', ->
      expect(@report.totalBytes()).to.equal(10887120)
