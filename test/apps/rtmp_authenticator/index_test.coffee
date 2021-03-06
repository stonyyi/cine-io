supertest = require('supertest')
Base = Cine.app('base')
RtmpAuthenticator = Cine.app('rtmp_authenticator').app
async = require('async')
EdgecastStream = Cine.server_model('edgecast_stream')
Project = Cine.server_model('project')

describe 'RtmpAuthenticator', ->

  beforeEach ->
    @agent = supertest.agent(RtmpAuthenticator)

  beforeEach (done)->
    @project = new Project
    @project.save done

  beforeEach (done)->
    @stream = new EdgecastStream(streamName: 'myStream', streamKey: 'myKey', _project: @project._id)
    @stream.save done

  beforeEach (done)->
    @deletedStream = new EdgecastStream(streamName: 'myStream2', streamKey: 'myKey', _project: @project._id, deletedAt: new Date)
    @deletedStream.save done

  describe '/', ->

    it "needs a name", (done)->
      @agent.post('/').expect(404).end (err, res)->
        expect(err).to.be.null
        expect(res.text).to.equal("no stream name provided")
        done()

    it "needs a valid stream name", (done)->
      @agent
        .post('/')
        .send(name: "_NOT_A_REAL_STREAM_")
        .expect(404)
        .end (err, res)->
          expect(err).to.be.null
          expect(res.text).to.contain("invalid stream")
          done()

    it "requires correct stream key", (done)->
      @agent
        .post('/')
        .send(name: "myStream")
        .expect(401)
        .end (err, res)->
          expect(err).to.be.null
          expect(res.text).to.contain("unauthorized")
          done()

    it "requires the stream not be deleted", (done)->
      @agent
        .post('/')
        .send(name: "myStream2", myKey: '')
        .expect(404)
        .end (err, res)->
          expect(err).to.be.null
          expect(res.text).to.contain("invalid stream")
          done()

    describe 'without a project', ->
      beforeEach (done)->
        @stream._project = undefined
        @stream.save done

      it "returns 404", (done)->
        @agent
          .post('/')
          .send(name: "myStream", myKey: '')
          .expect(404)
          .end (err, res)->
            expect(err).to.be.null
            expect(res.text).to.contain("could not find project")
            done()

    describe 'throttled projects', ->
      beforeEach (done)->
        @project.throttledAt = new Date
        @project.save done
      it "returns 402", (done)->
        @agent
          .post('/')
          .send(name: "myStream", myKey: '')
          .expect(402)
          .end (err, res)->
            expect(err).to.be.null
            expect(res.text).to.contain("project is disabled")
            done()

    describe 'success', ->

      it "succeeds if authentication is bypassed", (done)->
        @agent
          .post('/')
          .send({"0ffa" : "true"})
          .expect(200)
          .end (err, res)->
            expect(err).to.be.null
            expect(res.text).to.contain("OK")
            done()

      it "succeeds with the right stream name and key", (done)->
        @agent
          .post('/')
          .send(name: "myStream", myKey: '')
          .expect(200)
          .end (err, res)->
            expect(err).to.be.null
            expect(res.text).to.contain("OK")
            done()
