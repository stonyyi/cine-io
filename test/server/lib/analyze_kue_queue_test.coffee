analyzeKueQueue = Cine.server_lib('analyze_kue_queue')

describe 'analyzeKueQueue', ->
  beforeEach ->
    @jobs = Cine.server_lib('create_queue')(force: true)

  it 'returns when there are no jobs', (done)->
    analyzeKueQueue (err, result)->
      expect(err).to.be.null
      expect(result).to.deep.equal(active: 0, inactive: 0)
      done()

  describe 'with jobs', ->

    beforeEach (done)->
      @job = @jobs.create("first-queue", more: 'data')
      @job.save done

    beforeEach (done)->
      @job2 = @jobs.create("second-queue", some: 'data')
      @job2.save done

    beforeEach (done)->
      @job3 = @jobs.create("second-queue", again: 'data')
      @job3.save done

    beforeEach (done)->
      @job3.state 'active', done

    it 'is ok having some jobs in the queue and some active', (done)->
      analyzeKueQueue (err, result)->
        expect(err).to.be.null
        expect(result).to.deep.equal(active: 1, inactive: 2)
        done()

    describe 'active longer than 10 minutes', (done)->
      beforeEach (done)->
        d = new Date
        d.setMinutes(d.getMinutes() - 15)
        @job3.set 'updated_at', d.getTime(), done

      it 'sends an error when a job is active for longer than 10 minutes', (done)->
        analyzeKueQueue (err, result)->
          expect(err).to.equal("Jobs in active state longer than 10 minutes")
          expect(result).to.be.undefined
          done()

    describe 'inactive longer than 10 minutes', (done)->
      beforeEach (done)->
        d = new Date
        d.setMinutes(d.getMinutes() - 15)
        @job.set 'updated_at', d.getTime(), done

      it 'sends an error when a job is inactive for longer than 10 minutes', (done)->
        analyzeKueQueue (err, result)->
          expect(err).to.equal("Jobs in inactive state longer than 10 minutes")
          expect(result).to.be.undefined
          done()
