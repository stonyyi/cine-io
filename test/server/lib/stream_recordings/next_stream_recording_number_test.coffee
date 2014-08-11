nextStreamRecordingNumber = Cine.server_lib('stream_recordings/next_stream_recording_number')

describe 'nextStreamRecordingNumber', ->

  files = [
    {type: '-', name: 'abc.2.mp4'}
    {type: '-', name: 'abc.mp4'}
    {type: '-', name: 'def.mp4'}
    {type: '-', name: 'abc.1.mp4'}
    {type: '-', name: 'jkl.2.mp4'}
    {type: '-', name: 'abc.mp4'}
  ]

  it 'returns the same number regardles of current number', ->
    expect(nextStreamRecordingNumber("abc.mp4", files)).to.equal(3)
    expect(nextStreamRecordingNumber("abc.1.mp4", files)).to.equal(3)

  it 'can handle a single entry number', ->
    expect(nextStreamRecordingNumber("def.mp4", files)).to.equal(1)

  it 'will return 0 for the first entry list', ->
    expect(nextStreamRecordingNumber("ghi.mp4", files)).to.equal(0)

  it 'can handle missing prior recordings', ->
    expect(nextStreamRecordingNumber("jkl.mp4", files)).to.equal(3)
