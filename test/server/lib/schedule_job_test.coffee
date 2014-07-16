scheduleJob = Cine.server_lib('schedule_job')

describe 'scheduleJob', ->
  it "will throw an exception when trying to schedule a job that can't be scheduled", ->
    try
      scheduleJob('NOT A JOB')
    catch e
      expect(e.message).to.equal('NOT A JOB is not a possible job')

  describe 'success', ->
    it 'will pass on the jobName', (done)->
      ironIONock = requireFixture('nock/schedule_ironio_worker')('current_environment').nock
      scheduleJob 'current_environment', (err, body)->
        expect(err).to.be.null
        expect(body.id).to.equal('5359a10cac845a1dd20084ef')
        expect(ironIONock.isDone()).to.be.true
        done()

    it 'can pass on an optional payload', (done)->
      ironIONock = requireFixture('nock/schedule_ironio_worker')('current_environment', thisIsA: 'pload')
      scheduleJob 'current_environment', thisIsA: 'pload', (err, body)->
        expect(err).to.be.null
        expect(body.id).to.equal('5359a10cac845a1dd20084ef')
        expect(ironIONock.postBody.tasks).to.have.length(1)
        expect(JSON.parse(ironIONock.postBody.tasks[0].payload).jobPayload).to.deep.equal(thisIsA: 'pload')
        expect(ironIONock.nock.isDone()).to.be.true
        done()

    describe 'passing environment', ->
      it 'will pass along the environment', (done)->
        ironIONock = requireFixture('nock/schedule_ironio_worker')('current_environment')
        scheduleJob 'current_environment', (err, body)->
          expect(err).to.be.null
          expect(body.id).to.equal('5359a10cac845a1dd20084ef')
          expect(ironIONock.postBody.tasks).to.have.length(1)
          payload = JSON.parse(ironIONock.postBody.tasks[0].payload)
          expect(payload.environment.MONGOHQ_URL).to.equal(Cine.config('variables/mongo'))
          expect(payload.environment.MANDRILL_APIKEY).to.equal(Cine.config('variables/mandrill').api_key)
          expect(payload.environment.EDGECAST_TOKEN).to.equal(Cine.config('variables/edgecast').token)
          expect(payload.environment.EDGECAST_FTP_HOST).to.equal(Cine.config('variables/edgecast').ftp.host)
          expect(payload.environment.EDGECAST_FTP_USER).to.equal(Cine.config('variables/edgecast').ftp.user)
          expect(payload.environment.EDGECAST_FTP_PASSWORD).to.equal(Cine.config('variables/edgecast').ftp.password)
          expect(payload.environment.NODE_ENV).to.equal('test')
          expect(ironIONock.nock.isDone()).to.be.true
          done()
