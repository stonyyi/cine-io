test = Cine.require('apps/input_to_rtmp_streamer')
supertest = require('supertest')
cp = require('child_process')
FakeSpawn = Cine.require('test/helpers/fake_child_process_spawn')

describe 'input_to_rtmp_streamer', ->
  beforeEach ->
    @agent = supertest.agent(test.app)

  beforeEach ->
    @spawnStub = sinon.stub cp, 'spawn'
    @spawnStub.returns new FakeSpawn

  afterEach ->
    @spawnStub.restore()

  afterEach ->
    test._reset()

  it 'serves handles the root', (done)->
    @agent.get('/').expect(200).end(done)

  describe '/start', ->
    it 'requires a streamName', (done)->
      @agent
        .post('/start')
        .send(streamKey: "some key", input: 'some input')
        .expect(400).end(done)
    it 'requires a streamKey', (done)->
      @agent
        .post('/start')
        .send(streamName: "some name", input: 'some input')
        .expect(400).end(done)
    it 'requires an input', (done)->
      @agent
        .post('/start')
        .send(streamName: 'some name', streamKey: "some key")
        .expect(400).end(done)

    it 'starts a streamer', (done)->
      @agent
        .post('/start')
        .send(streamName: 'some name', streamKey: "some key", input: 'some input')
        .expect(200).end (err, res)=>
          expect(err).to.be.null
          expect(@spawnStub.calledOnce).to.be.true
          done()

  describe '/stop', ->
    beforeEach (done)->
      @agent
        .post('/start')
        .send(streamName: 'some name', streamKey: "some key", input: 'some input')
        .expect(200).end (err, res)->
          process.nextTick ->
            done(err)

    it 'stops a streamer', (done)->
      @agent
        .post('/stop')
        .send(streamName: 'some name')
        .expect(200).end (err, res)=>
          expect(err).to.be.null
          spawn = @spawnStub.firstCall.returnValue
          expect(spawn.kill.calledOnce).to.be.true
          done()
