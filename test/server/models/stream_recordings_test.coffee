StreamRecordings = Cine.server_model('stream_recordings')
modelTimestamps = Cine.require('test/helpers/model_timestamps')

describe 'StreamRecordings', ->
  modelTimestamps StreamRecordings, name: 'some name'

  addRecording = (recording, thisMonth, thisMonth2, lastMonth, twoMonthsAgo)->

    recording.recordings.push
      name: "abc"
      size: 3043079
      date: thisMonth

    recording.recordings.push
      name: "def"
      size: 7676745
      date: lastMonth

    recording.recordings.push
      name: "def"
      size: 7373737
      date: thisMonth2
      deletedAt: new Date

    recording.recordings.push
      name: "def"
      size: 9797948
      date: twoMonthsAgo
      deletedAt: thisMonth

  beforeEach (done)->
    @recording = new StreamRecordings
    @thisMonth = new Date
    console.log("This month", @thisMonth)
    @thisMonth2 = new Date
    if @thisMonth.getDate() == 1
      @thisMonth2.setDate(@thisMonth2.getDate() + 1)
    else
      @thisMonth2.setDate(@thisMonth2.getDate() - 1)

    @lastMonth = new Date
    @lastMonth.setDate(1)
    @lastMonth.setMonth(@lastMonth.getMonth() - 1)
    @twoMonthsAgo = new Date
    @twoMonthsAgo.setDate(1)
    @twoMonthsAgo.setMonth(@twoMonthsAgo.getMonth() - 2)

    addRecording(@recording, @thisMonth, @thisMonth2, @lastMonth, @twoMonthsAgo)
    @recording.save done

  describe '#bytesForMonth', ->
    it 'can calculate bytes for a month', ->
      expect(@recording.bytesForMonth(@thisMonth)).to.equal(3043079+7676745)

    it 'can calculate bytes for a month when recordings are deleted on that month', ->
      expect(@recording.bytesForMonth(@lastMonth)).to.equal(7676745+9797948)

    it 'can calculate bytes for a month where recording are deleted after that month', ->
      expect(@recording.bytesForMonth(@twoMonthsAgo)).to.equal(9797948)

  describe '#totalBytes', ->
    it 'can aggrigate all the entries ignoring deletedAt', ->
      expect(@recording.totalBytes()).to.equal(10719824)
