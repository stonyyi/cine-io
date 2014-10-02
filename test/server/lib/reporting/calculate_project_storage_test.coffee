Project = Cine.server_model('project')
EdgecastStream = Cine.server_model('edgecast_stream')
EdgecastRecordings = Cine.server_model('edgecast_recordings')
CalculateProjectStorage = Cine.server_lib('reporting/calculate_project_storage')

describe 'CalculateProjectStorage', ->

  beforeEach (done)->
    @project = new Project(name: 'the project')
    @project.save done
  beforeEach (done)->
    @stream1 = new EdgecastStream(_project: @project._id)
    @stream1.save done
  beforeEach (done)->
    @stream2 = new EdgecastStream(_project: @project._id)
    @stream2.save done
  beforeEach (done)->
    @notProjectStream = new EdgecastStream()
    @notProjectStream.save done

  addRecordings = (recording)->

    recording.recordings.push
      name: "abc"
      size: 3043079
      date: new Date

    recording.recordings.push
      name: "def"
      size: 7573983
      date: new Date

  createRecordingsForStream = (stream, done)->
    recordings = new EdgecastRecordings(_edgecastStream: stream)
    addRecordings(recordings)
    recordings.save done

  beforeEach (done)->
    createRecordingsForStream @stream1, done
  beforeEach (done)->
    createRecordingsForStream @stream2, done
  beforeEach (done)->
    createRecordingsForStream @notProjectStream, done

  describe '#total', ->

    it 'will aggregate all project streams', (done)->
      CalculateProjectStorage.total @project, (err, monthlyBytes)->
        expect(err).to.be.null
        expect(monthlyBytes).to.equal(21234124)
        done()
