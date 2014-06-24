async = require('async')
mailer = Cine.server_lib("mailer")

module.exports = (mailerName, nockOptions={})->
  stubMailer mailer, mailerName, nockOptions

module.exports.admin = (mailerName, nockOptions={})->
  stubMailer mailer.admin, mailerName, nockOptions

stubMailer = (mailerObject, mailerName, nockOptions)->
  beforeEach ->
    @emailMock = requireFixture('nock/send_template_email_success')(nockOptions)
    @mailerSpy = sinon.spy mailerObject, mailerName

  afterEach (done)->
    emailSent = false
    testFunction = -> emailSent
    checkFunction = (callback)=>
      emailSent =  @emailMock.isDone()
      setTimeout callback
    async.until testFunction, checkFunction, done

  afterEach ->
    expect(@mailerSpy.calledOnce).to.be.true
    @mailerSpy.restore()
