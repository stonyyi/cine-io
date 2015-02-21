_ = require('underscore')

threeDayNotificationMailer = Cine.server_lib('mailer/three_day_notification_mailer')
mandrill = Cine.server_lib('mailer/mandrill_template_mailer')._mandrill
Account = Cine.server_model('account')

describe 'threeDayNotificationMailer', ->

  beforeEach (done)->
    @account = new Account(name: 'my account name', billingEmail: 'my billing email', productPlans: {broadcast: ['basic', 'pro'], peer: ['business']}, billingProvider: 'cine.io')
    @account.save done

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

  accountMergeVars = (options, account)->
    _.find options.merge_vars, (mergeVar)->
      mergeVar.rcpt == account.billingEmail

  assertToAccount = (options, account, length=1)->
    expect(options.to).to.have.length(length)
    expect(options.merge_vars).to.have.length(length)
    accountVars = accountMergeVars(options, account)
    expect(accountVars.rcpt).to.equal(account.billingEmail)
    toAccount = _.find options.to, (toField)->
      toField.email == account.billingEmail
    expect(toAccount.name).to.equal(account.name)
    expect(toAccount.email).to.equal(account.billingEmail)

  assertMergeVarsInVars = (mergeVars, expectedMergeVars)->
    actualVars = mergeVars.vars
    expect(actualVars).to.have.length(_.keys(expectedMergeVars).length)
    injectLoop = (memo, varObj)->
      memo[varObj.name] = varObj.content
      return memo
    transformed = _.inject actualVars, injectLoop, {}
    expect(transformed).to.deep.equal(expectedMergeVars)

  describe 'haventDoneAnything', ->
    assertCorrectMergeVars = (mergeVars)->
      expectedMergeVars =
        header_blurb: "Welcome to cine.io."
        name: "my account name"
      expect(mergeVars.templateVars.content).to.include('Looks like you haven\'t streamed anything nor used any peer minutes.')
      expect(mergeVars.templateVars.content).to.include("If you have any questions")
      # content is huge, don't want to include it here
      expectedMergeVars.content = mergeVars.templateVars.content
      expect(mergeVars.templateVars).to.deep.equal(expectedMergeVars)
      assertMergeVarsInVars(mergeVars, expectedMergeVars)

    it 'sends the email', (done)->
      threeDayNotificationMailer.haventDoneAnything @account, (err, response)=>
        options = getMailOptions.call(this)
        expect(options.subject).to.equal("Welcome to cine.io.")
        assertToAccount(options, @account)
        assertCorrectMergeVars accountMergeVars(options, @account)
        assertMailSent.call(this, err, response, done)

  describe 'didSendBandwidth', ->
    assertCorrectMergeVars = (mergeVars)->
      expectedMergeVars =
        header_blurb: "Welcome to cine.io."
        name: "my account name"
      expect(mergeVars.templateVars.content).to.include('Looks like you were able to get setup using our live streaming broadcast product.')
      expect(mergeVars.templateVars.content).to.include("If you have any questions")
      # content is huge, don't want to include it here
      expectedMergeVars.content = mergeVars.templateVars.content
      expect(mergeVars.templateVars).to.deep.equal(expectedMergeVars)
      assertMergeVarsInVars(mergeVars, expectedMergeVars)

    it 'sends the email', (done)->
      threeDayNotificationMailer.didSendBandwidth @account, (err, response)=>
        options = getMailOptions.call(this)
        expect(options.subject).to.equal("Welcome to cine.io.")
        assertToAccount(options, @account)
        assertCorrectMergeVars accountMergeVars(options, @account)
        assertMailSent.call(this, err, response, done)

  describe 'didSendPeer', ->
    assertCorrectMergeVars = (mergeVars)->
      expectedMergeVars =
        header_blurb: "Welcome to cine.io."
        name: "my account name"
      expect(mergeVars.templateVars.content).to.include('Looks like you were able to get setup using our peer to peer chat product.')
      expect(mergeVars.templateVars.content).to.include("If you have any questions")
      # content is huge, don't want to include it here
      expectedMergeVars.content = mergeVars.templateVars.content
      expect(mergeVars.templateVars).to.deep.equal(expectedMergeVars)
      assertMergeVarsInVars(mergeVars, expectedMergeVars)

    it 'sends the email', (done)->
      threeDayNotificationMailer.didSendPeer @account, (err, response)=>
        options = getMailOptions.call(this)
        expect(options.subject).to.equal("Welcome to cine.io.")
        assertToAccount(options, @account)
        assertCorrectMergeVars accountMergeVars(options, @account)
        assertMailSent.call(this, err, response, done)
