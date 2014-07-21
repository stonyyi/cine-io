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
    @emailNocks ||= []
    @mailerSpies ||= []

  beforeEach ->
    # isDone() in nock does not respect .times(times)
    # but we can call nock multiple times and that will work
    _.times options.times, =>
      @emailNocks.push requireFixture('nock/send_template_email_success')()
    @mailerSpies.push sinon.spy mailerObject, mailerName

  afterEach (done)->
    emailSent = false
    testFunction = -> emailSent
    checkFunction = (callback)=>
      emailSent = _.all @emailNocks, nockIsDone
      setTimeout callback
    async.until testFunction, checkFunction, done

  afterEach ->
    _.each @mailerSpies, (spy)->
      expect(spy.calledOnce).to.be.true
      spy.restore()
    delete @emailNocks if @emailNocks
    delete @mailerSpies if @mailerSpies
