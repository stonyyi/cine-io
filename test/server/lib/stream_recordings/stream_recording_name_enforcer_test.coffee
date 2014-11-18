streamRecordingNameEnforcer = Cine.server_lib('stream_recordings/stream_recording_name_enforcer')

describe 'streamRecordingNameEnforcer', ->

  describe 'newFileName', ->
    files = [
      {type: '-', name: 'abc.2.mp4'}
      {type: '-', name: 'abc.mp4'}
      {type: '-', name: 'def.mp4'}
      {type: '-', name: 'abc.1.mp4'}
      {type: '-', name: 'jkl.2.mp4'}
      {type: '-', name: 'abc.mp4'}
    ]

    it 'returns the same number regardles of current number', ->
      expect(streamRecordingNameEnforcer.newFileName("abc.mp4", files)).to.equal("abc.3.mp4")
      expect(streamRecordingNameEnforcer.newFileName("abc.1.mp4", files)).to.equal("abc.3.mp4")

    it 'can handle a single entry number', ->
      expect(streamRecordingNameEnforcer.newFileName("def.mp4", files)).to.equal("def.1.mp4")

    it 'will the orgingal file for the first entry list', ->
      expect(streamRecordingNameEnforcer.newFileName("ghi.mp4", files)).to.equal("ghi.mp4")

    it 'can handle missing prior recordings', ->
      expect(streamRecordingNameEnforcer.newFileName("jkl.mp4", files)).to.equal("jkl.3.mp4")

    it 'works with an underscore the newFileName with a dot when there are multiple recordings', ->
      expect(streamRecordingNameEnforcer.newFileName("abc_123.mp4", files)).to.equal("abc_123.mp4")
      expect(streamRecordingNameEnforcer.newFileName("abc_1234.mp4", files)).to.equal("abc.3.mp4")

  describe 'extractStreamName', ->
    it 'works with no numbers', ->
      expect(streamRecordingNameEnforcer.extractStreamName("abc.mp4")).to.equal('abc')

    it 'works when there are 4 trailing numbers after an underscore', -> #yeah, thanks edgecast
      expect(streamRecordingNameEnforcer.extractStreamName("abc_123.mp4")).to.equal("abc_123")
      expect(streamRecordingNameEnforcer.extractStreamName("abc_1234.mp4")).to.equal("abc")

    it 'works with a dot numbers', ->
      expect(streamRecordingNameEnforcer.extractStreamName("abc.3.mp4")).to.equal('abc')

    it 'works with a dot and underscore numbers', ->
      expect(streamRecordingNameEnforcer.extractStreamName("e1RIjedUEg.1412521527733_4694.mp4")).to.equal('e1RIjedUEg')

  describe 'extractStreamNameFromHlsFile', ->
    it 'takes off the timestamp', ->
      fileName = "some-stream-1416271565425.ts"
      streamName = streamRecordingNameEnforcer.extractStreamNameFromHlsFile(fileName)
      expect(streamName).to.equal("some-stream")
    it 'works with a directory', ->
      fileName = "https://cine-io-hls.s3.amazonaws.com/some-stream-1416271565425.ts"
      streamName = streamRecordingNameEnforcer.extractStreamNameFromHlsFile(fileName)
      expect(streamName).to.equal("some-stream")

  describe 'extractStreamNameFromDirectory', ->
    it 'takes a full directory', ->
      expect(streamRecordingNameEnforcer.extractStreamNameFromDirectory("/some/full/path/abc.mp4")).to.equal('abc')

    it 'takes a full timestamp', ->
      expect(streamRecordingNameEnforcer.extractStreamNameFromDirectory("/some/full/path/xycITcxBEe.20141007T191714+0000.flv")).to.equal('xycITcxBEe')
