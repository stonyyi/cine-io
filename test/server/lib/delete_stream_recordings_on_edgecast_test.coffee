deleteStreamRecordingOnEdgecast = Cine.server_lib('delete_stream_recording_on_edgecast')
EdgecastStream = Cine.server_model('edgecast_stream')
FakeFtpClient = Cine.require('test/helpers/fake_ftp_client')

describe 'deleteStreamRecordingOnEdgecast', ->

  beforeEach ->
    @stream = new EdgecastStream(streamName: 'xkMOUbRPZl', instanceName: 'cines')
    @fakeFtpClient = new FakeFtpClient
    @deleteStub = @fakeFtpClient.stub('delete')
    @deleteStub.callsArgWith 1, null

  afterEach ->
    @fakeFtpClient.restore()

  it 'returns the files for a stream', (done)->
    deleteStreamRecordingOnEdgecast @stream, "myFunRecording", (err)=>
      expect(@deleteStub.calledOnce).to.be.true
      expect(@deleteStub.args[0][0]).to.equal('/cines/myFunRecording')
      expect(err).to.be.null
      done()
