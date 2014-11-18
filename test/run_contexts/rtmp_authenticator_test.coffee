supertest = require('supertest')
Base = Cine.run_context('base')
RtmpAuthenticator = Cine.run_context('rtmp_authenticator').app
async = require('async')
EdgecastStream = Cine.server_model('edgecast_stream')

describe 'RtmpAuthenticator', ->

  beforeEach (done)->
    @agent = supertest.agent(RtmpAuthenticator)
    @stream = new EdgecastStream(streamName: 'myStream', streamKey: 'myKey', record: false)
    @stream.save done

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

    it "has the correct stream key", (done)->
      @agent
        .post('/')
        .send(name: "myStream")
        .expect(401)
        .end (err, res)->
          expect(err).to.be.null
          expect(res.text).to.contain("unauthorized")
          done()

    describe 'success', ->

      it "succeeds with the right stream name and key", (done)->
        @agent
          .post('/')
          .send(name: "myStream", myKey: '')
          .expect(200)
          .end (err, res)->
            expect(err).to.be.null
            expect(res.text).to.contain("OK")
            done()
