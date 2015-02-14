Project = Cine.server_model('project')
EdgecastStream = Cine.server_model('edgecast_stream')
StreamRecordings = Cine.server_model('stream_recordings')
CalculateProjectStorage = Cine.server_lib('reporting/storage/calculate_project_storage')

describe 'CalculateProjectStorage', ->

  beforeEach (done)->
    @project = new Project(name: 'the project')
    @project.save done
  beforeEach (done)->
    @stream1 = new EdgecastStream(_project: @project._id, streamName: 'random-1')
    @stream1.save done
  beforeEach (done)->
    @stream2 = new EdgecastStream(_project: @project._id, streamName: 'random-2')
    @stream2.save done
  beforeEach (done)->
    @notProjectStream = new EdgecastStream(streamName: 'random-3')
    @notProjectStream.save done

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

  beforeEach ->
    @thisMonth = new Date
    @lastMonth = new Date
    @lastMonth.setDate(1)
    @lastMonth.setMonth(@lastMonth.getMonth() - 1)
    @twoMonthsAgo = new Date
    @twoMonthsAgo.setDate(1)
    @twoMonthsAgo.setMonth(@twoMonthsAgo.getMonth() - 2)

  beforeEach (done)->
    createRecordingsForStream @stream1, @thisMonth, @lastMonth, done
  beforeEach (done)->
    createRecordingsForStream @stream2, @thisMonth, @lastMonth, done
  beforeEach (done)->
    createRecordingsForStream @notProjectStream, @thisMonth, @lastMonth, done

  describe '#byMonth', ->
    it 'can aggrigate for this month', (done)->
      CalculateProjectStorage.byMonth @project, @thisMonth, (err, monthlyBytes)->
        expect(err).to.be.null
        # 15,147,966
        expect(monthlyBytes).to.equal((3043079+7573983+93737)*2)
        done()

    it 'can aggrigate by last month', (done)->
      CalculateProjectStorage.byMonth @project, @lastMonth, (err, monthlyBytes)->
        expect(err).to.be.null
        expect(monthlyBytes).to.equal((3043079+93737)*2)
        done()

    it 'can aggrigate by two months ago', (done)->
      CalculateProjectStorage.byMonth @project, @twoMonthsAgo, (err, monthlyBytes)->
        expect(err).to.be.null
        expect(monthlyBytes).to.equal(0)
        done()

  describe '#total', ->

    it 'will aggregate all project recordings', (done)->
      CalculateProjectStorage.total @project, (err, monthlyBytes)->
        expect(err).to.be.null
        expect(monthlyBytes).to.equal((3043079+7573983+93737)*2)
        done()
