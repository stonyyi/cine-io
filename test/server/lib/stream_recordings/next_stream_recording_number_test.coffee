nextStreamRecordingNumber = Cine.server_lib('stream_recordings/next_stream_recording_number')

describe 'nextStreamRecordingNumber', ->

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
      expect(nextStreamRecordingNumber.newFileName("abc.mp4", files)).to.equal("abc.3.mp4")
      expect(nextStreamRecordingNumber.newFileName("abc.1.mp4", files)).to.equal("abc.3.mp4")

    it 'can handle a single entry number', ->
      expect(nextStreamRecordingNumber.newFileName("def.mp4", files)).to.equal("def.1.mp4")

    it 'will the orgingal file for the first entry list', ->
      expect(nextStreamRecordingNumber.newFileName("ghi.mp4", files)).to.equal("ghi.mp4")

    it 'can handle missing prior recordings', ->
      expect(nextStreamRecordingNumber.newFileName("jkl.mp4", files)).to.equal("jkl.3.mp4")

    xit 'works with an underscore the newFileName with a dot when there are multiple recordings', ->
      expect(nextStreamRecordingNumber.newFileName("abc_123.mp4", files)).to.equal("abc.3.mp4")

  describe 'extractStreamName', ->
    it 'works with no numbers', ->
      expect(nextStreamRecordingNumber.extractStreamName("abc.mp4")).to.equal('abc')

    xit 'works with an underscore numbers', ->
      expect(nextStreamRecordingNumber.extractStreamName("abc_123.mp4", files)).to.equal("abc")

    it 'works with a dot numbers', ->
      expect(nextStreamRecordingNumber.extractStreamName("abc.3.mp4")).to.equal('abc')
