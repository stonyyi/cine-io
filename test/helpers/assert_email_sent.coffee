async = require('async')
mailer = Cine.server_lib("mailer")
_ = require('underscore')

module.exports = (mailerName, options={})->
  stubMailer mailer, mailerName, options

module.exports.admin = (mailerName, options={})->
  stubMailer mailer.admin, mailerName, options

nockIsDone = (thisNock)->
  thisNock.isDone()

stubMailer = (mailerObject, mailerName, options)->
  options.times ||= 1
  beforeEach ->
    @emailNocks = []
    # isDone() in nock does not respect .times(times)
    # but we can call nock multiple times and that will work
    _.times options.times, =>
      @emailNocks.push requireFixture('nock/send_template_email_success')()
    @mailerSpy = sinon.spy mailerObject, mailerName

  afterEach (done)->
    emailSent = false
    testFunction = -> emailSent
    checkFunction = (callback)=>
      emailSent = _.all @emailNocks, nockIsDone
      setTimeout callback
    async.until testFunction, checkFunction, done

  afterEach ->
    expect(@mailerSpy.calledOnce).to.be.true
    @mailerSpy.restore()
