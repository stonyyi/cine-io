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
    it 'passes a callback to a library that takes 1 argument', (done)->
      justACallback = (callback)->
        callback(null, 'my response')
      jobStub = sinon.stub Cine, 'server_lib', -> justACallback
      jobStub.withArgs('current_environment')
      doWork 'current_environment', {}, (err, response)->
        expect(response).to.equal('my response')
        jobStub.restore()
        done()

    it 'passes a callback and payload to a library that takes 2 arguments', (done)->
      callbackAndPayload = (payload, callback)->
        callback(null, first: 'part', the: payload.thing)
      jobStub = sinon.stub Cine, 'server_lib', -> callbackAndPayload
      jobStub.withArgs('current_environment')
      doWork 'current_environment', some: 'part', thing: 12, (err, response)->
        expect(response).to.deep.equal(first: 'part', the: 12)
        jobStub.restore()
        done()
