_ = require('underscore')
accountMailer = Cine.server_lib('mailer/account_mailer')
mandrill = Cine.server_lib('mailer/mandrill_template_mailer')._mandrill
User = Cine.server_model('user')
Account = Cine.server_model('account')
AccountBillingHistory = Cine.server_model('account_billing_history')
PasswordChangeRequest = Cine.server_model('password_change_request')
humanizeBytes = Cine.lib('humanize_bytes')
moment = require('moment')

describe 'accountMailer', ->

  beforeEach (done)->
    @user = new User(name: 'my name', email: 'my email')
    @user.save done

  beforeEach (done)->
    @account = new Account(name: 'my account name', billingEmail: 'my billing email', plans: ['basic', 'pro'], billingProvider: 'cine.io')
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

  userMergeVars = (options, user)->
    _.find options.merge_vars, (mergeVar)->
      mergeVar.rcpt == user.email

  accountMergeVars = (options, account)->
    _.find options.merge_vars, (mergeVar)->
      mergeVar.rcpt == account.billingEmail

  assertToUser = (options, user, length=1)->
    expect(options.to).to.have.length(length)
    expect(options.merge_vars).to.have.length(length)
    userVars = userMergeVars(options, user)
    expect(userVars.rcpt).to.equal(user.email)
    toUser = _.find options.to, (toField)->
      toField.email == user.email
    expect(toUser.name).to.equal(user.name)
    expect(toUser.email).to.equal(user.email)

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

  describe 'monthlyBill', ->
    beforeEach (done)->
      results =
        billing:
          plan: 500
          bandwidthOverage: 340
          storageOverage: 290
        usage:
          bandwidth: humanizeBytes.TiB
          storage: humanizeBytes.GiB * 2
          bandwidthOverage: humanizeBytes.Gib * 5
          storageOverage: humanizeBytes.Gib * 2
      @now = new Date
      @abh = new AccountBillingHistory(_account: @account._id)
      @abh.history.push
        stripeChargeId: 'this month charge'
        billingDate: @now
        billedAt: new Date
        details: results
        accountPlans: @account.plans

      lastMonth = new Date
      lastMonth.setMonth(lastMonth.getMonth() - 1)
      @abh.history.push
        billingDate: lastMonth
        stripeChargeId: 'last month charge'
      @abh.save done

    assertCorrectMergeVars = (mergeVars, billingMonthDate)->
      month = moment(billingMonthDate).format("MMM YYYY")
      expectedMergeVars =
        header_blurb: "Thank you for using cine.io."
        ACCOUNT_NAME: "my account name"
        BILLING_MONTH: month
        BILL_BANDWIDTH_OVERAGE: "0 bytes @ $0.70 / GiB = $3.40"
        BILL_OVERAGE_TOTAL: "$6.30"
        BILL_STORAGE_OVERAGE: "0 bytes @ $0.70 / GiB = $2.90"
        BILL_TOTAL: "$11.30"
        PLAN_BANDWIDTH: "1.15 TiB"
        PLAN_COST: "$5.00"
        PLAN_STORAGE: "125.00 GiB"
        USAGE_BANDWIDTH: "1.00 TiB"
        USAGE_PLAN: "Basic and Pro"
        USAGE_STORAGE: "2.00 GiB"
      expect(mergeVars.templateVars).to.deep.equal(expectedMergeVars)
      assertMergeVarsInVars(mergeVars, expectedMergeVars)

    it 'sends the billing email', (done)->
      accountMailer.monthlyBill @account, @abh, @now, (err, response)=>
        options = getMailOptions.call(this)
        expect(options.subject).to.equal("Your cine.io invoice")
        assertToAccount(options, @account)
        assertCorrectMergeVars accountMergeVars(options, @account), @now
        assertMailSent.call(this, err, response, done)

  describe 'underOneGibBill', ->
    beforeEach (done)->
      results =
        billing:
          plan: 500
          bandwidthOverage: 0
          storageOverage: 0
        usage:
          bandwidth: humanizeBytes.GiB * 0.9
          storage: humanizeBytes.GiB * 0.9
          bandwidthOverage: 0
          storageOverage: 0
      @now = new Date
      @abh = new AccountBillingHistory(_account: @account._id)
      @abh.history.push
        stripeChargeId: 'this month charge'
        billingDate: @now
        billedAt: new Date
        details: results
        accountPlans: @account.plans

      lastMonth = new Date
      lastMonth.setMonth(lastMonth.getMonth() - 1)
      @abh.history.push
        billingDate: lastMonth
        stripeChargeId: 'last month charge'
      @abh.save done

    assertCorrectMergeVars = (mergeVars, billingMonthDate)->
      month = moment(billingMonthDate).format("MMM YYYY")

      expectedMergeVars =
        header_blurb: "Have #{month} on us."
        name: "my account name"
      expect(mergeVars.templateVars.content).to.include("This is normally when bills come around. Your bandwidth usage was under 1 GiB so have #{month} on us.")
      # content is huge, don't want to include it here
      expectedMergeVars.content = mergeVars.templateVars.content

      expect(mergeVars.templateVars).to.deep.equal(expectedMergeVars)
      assertMergeVarsInVars(mergeVars, expectedMergeVars)

    it 'sends the not a bill email', (done)->
      accountMailer.underOneGibBill @account, @abh, @now, (err, response)=>
        options = getMailOptions.call(this)
        expect(options.subject).to.equal("Your non-invoice for cine.io.")
        assertToAccount(options, @account)
        assertCorrectMergeVars accountMergeVars(options, @account), @now
        assertMailSent.call(this, err, response, done)

  describe 'throttledAccount', ->

    assertCorrectMergeVars = (mergeVars)->

      expectedMergeVars =
        header_blurb: "Please update your account"
        name: "my account name"
      expect(mergeVars.templateVars.content).to.include("All api requests will begin returning a 402 response.")
      expect(mergeVars.templateVars.content).to.include("Please upgrade your account at <a href=\"https://www.cine.io/account\">https://www.cine.io/account</a>.")
      # content is huge, don't want to include it here
      expectedMergeVars.content = mergeVars.templateVars.content

      expect(mergeVars.templateVars).to.deep.equal(expectedMergeVars)
      assertMergeVarsInVars(mergeVars, expectedMergeVars)

    it 'sends a throttled account email', (done)->
      accountMailer.throttledAccount @account, (err, response)=>
        options = getMailOptions.call(this)
        expect(options.subject).to.equal("Your account has been throttled.")
        assertToAccount(options, @account)
        assertCorrectMergeVars accountMergeVars(options, @account)
        assertMailSent.call(this, err, response, done)
