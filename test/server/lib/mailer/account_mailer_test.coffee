_ = require('underscore')
accountMailer = Cine.server_lib('mailer/account_mailer')
mandrill = Cine.server_lib('mailer/mandrill_template_mailer')._mandrill
User = Cine.server_model('user')
PasswordChangeRequest = Cine.server_model('password_change_request')

describe 'accountMailer', ->

  beforeEach (done)->
    @user = new User(name: 'my name', email: 'my email')
    @user.save done

  beforeEach ->
    @templateEmailSuccess = requireFixture('nock/send_template_email_success')()

  beforeEach ->
    @mandrillStub = sinon.spy mandrill.messages, 'sendTemplate'

  afterEach ->
    @mandrillStub.restore()

  assertMailSent = (err, response, done)->
    expect(err).to.be.null
    expect(response).to.have.length(1)
    expect(response[0].status).to.equal('sent')
    expect(@templateEmailSuccess.isDone()).to.be.true
    done()

  getMailOptions = ->
    @mandrillStub.firstCall.args[0].message

  userMergeVars = (options, user)->
    _.find options.merge_vars, (mergeVar)->
      mergeVar.rcpt == user.email

  assertToUser = (options, user, length=1)->
    expect(options.to).to.have.length(length)
    expect(options.merge_vars).to.have.length(length)
    userVars = userMergeVars(options, user)
    expect(userVars.rcpt).to.equal(user.email)
    toUser = _.find options.to, (toField)->
      toField.email == user.email
    expect(toUser.name).to.equal(user.name)
    expect(toUser.email).to.equal(user.email)

  assertMergeVarsInVars = (mergeVars, expectedMergeVars)->
    actualVars = mergeVars.vars
    expect(actualVars).to.have.length(_.keys(expectedMergeVars).length)
    injectLoop = (memo, varObj)->
      memo[varObj.name] = varObj.content
      return memo
    transformed = _.inject actualVars, injectLoop, {}
    expect(transformed).to.deep.equal(expectedMergeVars)

  describe 'forgotPassword', ->
    beforeEach (done)->
      @passwordChangeRequest = new PasswordChangeRequest(_user: @user)
      @passwordChangeRequest.save done

    assertCorrectMergeVars = (mergeVars, identifier)->
      expectedMergeVars =
        action_copy: "Click here to reset your password."
        action_url: "https://localtest.me:8181/recover-password/#{identifier}"
        followup_copy: "<p>If this is a mistake just ignore this email &mdash; your password will not be changed.</p>"
        header_blurb: "Reset your password"
        lead_copy: "<p>Someone recently requested that the password be reset for my email.</p>"
        name: "my name"
      expect(mergeVars.templateVars).to.deep.equal(expectedMergeVars)
      assertMergeVarsInVars(mergeVars, expectedMergeVars)

    it 'sends an email reminding them of their password', (done)->
      accountMailer.forgotPassword @user, @passwordChangeRequest, (err, response)=>
        options = getMailOptions.call(this)
        expect(options.subject).to.equal("Reset your password")
        assertToUser(options, @user)
        assertCorrectMergeVars userMergeVars(options, @user), @passwordChangeRequest.identifier
        assertMailSent.call(this, err, response, done)

  describe 'welcomeEmail', ->
    assertCorrectMergeVars = (mergeVars)->
      expectedMergeVars =
        header_blurb: "Welcome to cine.io."
        name: "my name"
      expect(mergeVars.templateVars.content).to.include('<a href="https://github.com/cine-io/js-sdk">JavaScript SDK</a>')
      expect(mergeVars.templateVars.content).to.include("<a href='https://www.cine.io/docs'>documentation page</a>")
      # content is huge, don't want to include it here
      expectedMergeVars.content = mergeVars.templateVars.content
      expect(mergeVars.templateVars).to.deep.equal(expectedMergeVars)
      assertMergeVarsInVars(mergeVars, expectedMergeVars)

    it 'sends the welcome email', (done)->
      accountMailer.welcomeEmail @user, (err, response)=>
        options = getMailOptions.call(this)
        expect(options.subject).to.equal("Welcome to cine.io.")
        assertToUser(options, @user)
        assertCorrectMergeVars userMergeVars(options, @user)
        assertMailSent.call(this, err, response, done)
