doWork = Cine.require('worker/lib/do_work')
_ = require('underscore')

describe 'doWork', ->
  it 'will not run an unacceptable job', (done)->
    doWork 'NOT A JOB', {}, (err, response)->
      expect(err).to.equal('unacceptable job')
      done()

  describe 'acceptableJobs', ->
    it 'ensures they are all valid server files', ->
      missingFiles = _.reject doWork.acceptableJobs, Cine.server_lib
      console.error('Not a server lib:', missingFiles) if missingFiles.length > 0
      expect(missingFiles).to.have.length(0)

  describe 'success', ->

    describe 'scheduled tasks', ->
      schedulableJobs = [
        {
          name: 'once_an_hour_worker'
          libs: [
            'reporting/broadcast/download_and_parse_edgecast_logs'
            'reporting/broadcast/download_and_parse_cloudfront_logs'
            'stats/calculate_and_save_usage_stats'
            'billing/update_or_throttle_accounts_who_cannot_pay_for_overages'
          ]
        }
      ]
      _.each schedulableJobs, (schedulableJob)->

        it "calls each task for #{schedulableJob.name}", (done)->
          calledFirstCallback = false
          justACallback = (callback)->
            calledFirstCallback = true
            callback()
          jobStub = sinon.stub Cine, 'server_lib', -> justACallback
          jobStub.withArgs(schedulableJob.libs)
          doWork schedulableJob.name, {}, (err, response)->
            expect(jobStub.firstCall.args).to.deep.equal([schedulableJob.libs[0]])
            expect(jobStub.secondCall.args).to.deep.equal([schedulableJob.libs[1]])
            expect(jobStub.thirdCall.args).to.deep.equal([schedulableJob.libs[2]])
            expect(jobStub.getCall(3).args).to.deep.equal([schedulableJob.libs[3]])
            jobStub.restore()
            expect(err).be.undefined
            expect(response).to.be.undefined
            expect(calledFirstCallback).to.be.true
            done()

    describe 'one off tasks', ->

      it 'passes a callback to a library that takes 1 argument', (done)->
        justACallback = (callback)->
          callback(null, 'my response')
        jobStub = sinon.stub Cine, 'server_lib', -> justACallback
        jobStub.withArgs('current_environment')
        doWork 'current_environment', {}, (err, response)->
          jobStub.restore()
          expect(response).to.equal('my response')
          done()

      it 'passes a callback and payload to a library that takes 2 arguments', (done)->
        callbackAndPayload = (payload, callback)->
          callback(null, first: 'part', the: payload.thing)
        jobStub = sinon.stub Cine, 'server_lib', -> callbackAndPayload
        jobStub.withArgs('current_environment')
        doWork 'current_environment', some: 'part', thing: 12, (err, response)->
          jobStub.restore()
          expect(response).to.deep.equal(first: 'part', the: 12)
          done()
