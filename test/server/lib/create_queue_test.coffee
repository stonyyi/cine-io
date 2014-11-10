createQueue = Cine.server_lib('create_queue')

describe 'createQueue', ->
  it 'creates a new jobs object', ->
    jobs = createQueue()
    expect(jobs.client.prefix).to.equal('kue')
    expect(jobs.client.connection_id).to.be.a(Number.name)

  it 'returns the same object when called twice', ->
    jobs = createQueue()
    jobs.someWeirdKey = "HELLO WEIRD KEY"
    expect(jobs.someWeirdKey).to.equal('HELLO WEIRD KEY')
    jobs2 = createQueue()
    expect(jobs2.someWeirdKey).to.equal('HELLO WEIRD KEY')

  describe 'force override', ->
    it 'shutsdowns the existing jobs', ->
      jobs = createQueue()
      shutdownSpy = sinon.spy jobs, 'shutdown'
      jobs2 = createQueue(force: true)
      expect(shutdownSpy.calledOnce).to.be.true
      expect(shutdownSpy.firstCall.args).to.have.length(0)

    it 'returns a new jobs', ->
      jobs = createQueue()
      jobs.someWeirdKey = "HELLO WEIRD KEY"
      expect(jobs.someWeirdKey).to.equal('HELLO WEIRD KEY')
      jobs2 = createQueue(force: true)
      expect(jobs2.someWeirdKey).to.be.undefined
