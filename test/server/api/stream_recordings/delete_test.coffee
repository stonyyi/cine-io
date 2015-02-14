_ = require('underscore')
FakeFtpClient = Cine.require('test/helpers/fake_ftp_client')
Delete = testApi Cine.api('stream_recordings/delete')
Project = Cine.server_model('project')
EdgecastStream = Cine.server_model('edgecast_stream')
StreamRecordings = Cine.server_model('stream_recordings')

describe 'StreamRecordings#Delete', ->

  testApi.requresApiKey Delete, 'secret'

  now = new Date

  beforeEach (done)->
    @project = new Project(name: 'my project', publicKey: 'this-pub')
    @project.save done

  beforeEach (done)->
    @projectStream = new EdgecastStream
      instanceName: 'cines'
      eventName: 'xkMOUbRPZl'
      streamName: 'xkMOUbRPZl'
      streamKey: 'bass35'
      name: 'my fun name'
      _project: @project._id
      assignedAt: now
    @projectStream.save done

  beforeEach (done)->
    @notProjectStream = new EdgecastStream(instanceName: 'cines', streamName: 'name')
    @notProjectStream.save done

  beforeEach (done)->
    @recordings = new StreamRecordings(_edgecastStream: @projectStream._id)
    @recordings.recordings.push name: "rec1.mp4", size: 12345, date: new Date
    @recordings.recordings.push name: "abc", size: 67890, date: new Date
    @recordings.recordings.push name: "rec3.mp4", size: 98765, date: new Date
    @recordings.recordings.push name: "rec4.mp4", size: 98765, date: new Date, deletedAt: new Date
    @recordings.save done

  describe 'failure', ->
    it 'requires an id', (done)->
      params = secretKey: @project.secretKey
      Delete params, (err, response, options)->
        expect(err).to.equal('id required')
        expect(response).to.be.null
        expect(options.status).to.equal(400)
        done()

    it 'will not return a stream not owned by a different project', (done)->
      params = secretKey: @project.secretKey, id: @notProjectStream._id
      Delete params, (err, response, options)->
        expect(err).to.equal('stream not found')
        expect(response).to.be.null
        expect(options.status).to.equal(404)
        done()

    it 'requires a name to delete', (done)->
      params = secretKey: @project.secretKey, id: @projectStream._id
      Delete params, (err, response, options)->
        expect(err).to.equal('name required')
        expect(response).to.be.null
        expect(options.status).to.equal(404)
        done()

    describe 'invalid name', ->
      beforeEach (done)->
        @recordings = new StreamRecordings(_edgecastStream: @projectStream._id)
        @recordings.recordings.push name: "rec1.mp4", size: 12345, date: new Date
        @recordings.recordings.push name: "abc", size: 67890, date: new Date
        @recordings.save done
      it 'errors when the stream recording does not contain that name', (done)->
        params = secretKey: @project.secretKey, id: @projectStream._id, name: 'def'
        Delete params, (err, response, options)->
          expect(err).to.equal('recording not found')
          expect(response).to.be.null
          expect(options.status).to.equal(404)
          done()

    it 'returns 404 on a previously deleted recordings', (done)->
      params = secretKey: @project.secretKey, id: @projectStream._id, name: "rec4.mp4"
      Delete params, (err, response, options)->
        expect(err).to.equal('recording not found')
        expect(response).to.be.null
        expect(options.status).to.equal(404)
        done()

  describe 'success', ->

    beforeEach ->
      @s3Nock = requireFixture('nock/aws/delete_file_s3_success')('cine-io-vod', 'cines/this-pub/abc')

    it 'returns a deleted at flag', (done)->
      params = secretKey: @project.secretKey, id: @projectStream._id, name: "abc"
      Delete params, (err, response, options)->
        expect(err).to.be.null
        expect(options).to.be.undefined
        expect(_.keys(response)).to.deep.equal(['deletedAt'])
        expect(response.deletedAt).to.be.instanceOf(Date)
        done()

    it 'returns deletes on s3', (done)->
      params = secretKey: @project.secretKey, id: @projectStream._id, name: "abc"
      Delete params, (err, response, options)=>
        expect(@s3Nock.isDone()).to.be.true
        done()

    it 'deletes the stream recording entry', (done)->
      firstRecording = @recordings.recordings[1]
      expect(firstRecording.name).to.equal('abc')
      expect(firstRecording.deletedAt).to.be.undefined
      params = secretKey: @project.secretKey, id: @projectStream._id, name: "abc"
      Delete params, (err, response, options)=>
        StreamRecordings.findById @recordings._id, (err, recordings)->
          expect(recordings.recordings).to.have.length(4)
          firstRecording = recordings.recordings[1]
          expect(firstRecording.name).to.equal("abc")
          expect(firstRecording.deletedAt).to.be.instanceOf(Date)
          done()
