deleteStreamRecordingOnS3 = Cine.server_lib('stream_recordings/delete_stream_recording_on_s3')
Project = Cine.server_model("project")

describe 'deleteStreamRecordingOnS3', ->
  beforeEach (done)->
    @project = new Project publicKey: 'some-pub'
    @project.save done

  beforeEach ->
    @s3Nock = requireFixture('nock/aws/delete_file_s3_success')('cine-io-vod', 'cines/some-pub/some-name.mp4')

  it 'deletes the recording on s3', (done)->
    deleteStreamRecordingOnS3 @project, 'some-name.mp4', (err)=>
      expect(err).to.be.undefined
      expect(@s3Nock.isDone()).to.be.true
      done()
