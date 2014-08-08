numberOfStreamRecordings = Cine.server_lib('stream_recordings/number_of_stream_recordings')

describe 'numberOfStreamRecordings', ->

  files = [
    {type: '-', name: 'abc.mp4'}
    {type: '-', name: 'def.mp4'}
    {type: '-', name: 'abc.mp4'}
    {type: '-', name: 'abc.1.mp4'}
    {type: '-', name: 'def.1.mp4'}
    {type: '-', name: 'abc.2.mp4'}
  ]
  it 'returns the number of stream recordings in an ftp list', ->
    expect(numberOfStreamRecordings("abc.mp4", files)).to.equal(4)
    expect(numberOfStreamRecordings("abc.1.mp4", files)).to.equal(4)
    expect(numberOfStreamRecordings("def.mp4", files)).to.equal(2)
    expect(numberOfStreamRecordings("ghi.mp4", files)).to.equal(0)
