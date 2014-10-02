EdgecastRecordings = Cine.server_model('edgecast_recordings')
modelTimestamps = Cine.require('test/helpers/model_timestamps')

describe 'EdgecastRecordings', ->
  modelTimestamps EdgecastRecordings, name: 'some name'

  addRecording = (recording)->

    recording.recordings.push
      name: "abc"
      size: 3043079
      date: new Date

    recording.recordings.push
      name: "def"
      size: 7676745
      date: new Date

  beforeEach (done)->
    @recording = new EdgecastRecordings
    addRecording(@recording)
    @recording.save done

  describe '#totalBytes', ->

    it 'can aggrigate all the entries', ->
      expect(@recording.totalBytes()).to.equal(10719824)
