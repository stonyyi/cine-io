listArchivedStreamFiles = Cine.server_lib('list_archived_stream_files')
EdgecastStream = Cine.server_model('edgecast_stream')
FakeFtpClient = Cine.require('test/helpers/fake_ftp_client')

describe 'listArchivedStreamFiles', ->

  beforeEach ->
    @stream = new EdgecastStream(streamName: 'xkMOUbRPZl', instanceName: 'cines')
    @fakeFtpClient = new FakeFtpClient
    @listStub = @fakeFtpClient.stub('list')
    @lists = Cine.require('test/fixtures/edgecast_stream_archives')
    @listStub.callsArgWith 1, null, @lists

  afterEach ->
    @fakeFtpClient.restore()

  it 'returns the files for a stream', (done)->
    @fakeFtpClient.start()
    listArchivedStreamFiles @stream, (err, archivedStreams)=>
      expect(@listStub.calledOnce).to.be.true
      expect(@listStub.args[0][0]).to.equal('/cines')
      expect(err).to.be.null
      expect(archivedStreams).to.have.length(3)
      expect(archivedStreams[0].name).to.equal('xkMOUbRPZl.1.mp4')
      expect(archivedStreams[0].size).to.equal(7782264)
      expect(archivedStreams[1].name).to.equal('xkMOUbRPZl.2.mp4')
      expect(archivedStreams[1].size).to.equal(110410741)
      expect(archivedStreams[2].name).to.equal('xkMOUbRPZl.mp4')
      expect(archivedStreams[2].size).to.equal(4684422)
      done()
