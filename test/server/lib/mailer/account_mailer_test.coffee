_ = require('underscore')

accountMailer = Cine.server_lib('mailer/account_mailer')
mandrill = Cine.server_lib('mailer/mandrill_template_mailer')._mandrill
User = Cine.server_model('user')
Account = Cine.server_model('account')
AccountBillingHistory = Cine.server_model('account_billing_history')
PasswordChangeRequest = Cine.server_model('password_change_request')
humanizeBytes = Cine.lib('humanize_bytes')
moment = require('moment')

THOUSAND = 1000
MINUTES = 60 * THOUSAND # in milliseconds

describe 'accountMailer', ->

  beforeEach (done)->
    @user = new User(name: 'my name', email: 'my email')
    @user.save done

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
      expect(mergeVars.templateVars.content).to.include('<a href="https://github.com/cine-io/broadcast-js-sdk">JavaScript SDK</a>')
      expect(mergeVars.templateVars.content).to.include("<a href='http://developer.cine.io/'>documentation page</a>")
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

  describe 'automaticallyUpgradedAccount', ->
    assertCorrectMergeVars = (newPlan, mergeVars)->
      expectedMergeVars =
        header_blurb: "Account upgraded to #{newPlan}."
        name: "my account name"
      expect(mergeVars.templateVars.content).to.include("We have upgraded your account to #{newPlan}.")
      expect(mergeVars.templateVars.content).to.include("If you have any questions")
      # content is huge, don't want to include it here
      expectedMergeVars.content = mergeVars.templateVars.content
      expect(mergeVars.templateVars).to.deep.equal(expectedMergeVars)
      assertMergeVarsInVars(mergeVars, expectedMergeVars)

    it 'sends the email for broadcast', (done)->
      accountMailer.automaticallyUpgradedAccount @account, broadcast: "some-old-plan", (err, response)=>
        options = getMailOptions.call(this)
        expect(options.subject).to.equal("Account upgraded your cine.io account plan based on usage.")
        assertToAccount(options, @account)
        assertCorrectMergeVars "basic", accountMergeVars(options, @account)
        assertMailSent.call(this, err, response, done)

    it 'sends the email for peer', (done)->
      accountMailer.automaticallyUpgradedAccount @account, peer: "some-old-plan", (err, response)=>
        options = getMailOptions.call(this)
        expect(options.subject).to.equal("Account upgraded your cine.io account plan based on usage.")
        assertToAccount(options, @account)
        assertCorrectMergeVars "business", accountMergeVars(options, @account)
        assertMailSent.call(this, err, response, done)

  describe 'willUpgradeAccount', ->
    assertCorrectMergeVars = (mergeVars)->
      expectedMergeVars =
        header_blurb: "Account reaching usage limit."
        name: "my account name"
      expect(mergeVars.templateVars.content).to.include('upgrade your account to some-new-plan.')
      expect(mergeVars.templateVars.content).to.include("If you have any questions")
      # content is huge, don't want to include it here
      expectedMergeVars.content = mergeVars.templateVars.content
      expect(mergeVars.templateVars).to.deep.equal(expectedMergeVars)
      assertMergeVarsInVars(mergeVars, expectedMergeVars)

    it 'sends the email', (done)->
      accountMailer.willUpgradeAccount @account, "some-new-plan", (err, response)=>
        options = getMailOptions.call(this)
        expect(options.subject).to.equal("Account reaching usage limit.")
        assertToAccount(options, @account)
        assertCorrectMergeVars accountMergeVars(options, @account)
        assertMailSent.call(this, err, response, done)

  describe 'monthlyBill', ->
    describe 'all normal', ->
      beforeEach (done)->
        results =
          billing:
            plan: 500
            bandwidthOverage: 0
            storageOverage: 0
          usage:
            bandwidth: humanizeBytes.TiB
            storage: humanizeBytes.GiB * 2
            peerMilliseconds: 123 * THOUSAND * MINUTES
            bandwidthOverage: humanizeBytes.Gib * 5
            storageOverage: humanizeBytes.Gib * 2
        @now = new Date
        @abh = new AccountBillingHistory(_account: @account._id)
        @abh.history.push
          stripeChargeId: 'this month charge'
          billingDate: @now
          billedAt: new Date
          details: results
          accountPlans: @account.productPlans
          paid: true

        lastMonth = new Date
        lastMonth.setDate(1)
        lastMonth.setMonth(lastMonth.getMonth() - 1)
        @abh.history.push
          billingDate: lastMonth
          stripeChargeId: 'last month charge'
          paid: true
        @abh.save done

      assertCorrectMergeVars = (mergeVars, billingMonthDate)->
        month = moment(billingMonthDate).format("MMM YYYY")
        expectedMergeVars =
          header_blurb: "Thank you for using cine.io."
          ACCOUNT_NAME: "my account name"
          BILLING_MONTH: month
          BILL_TOTAL: "$5.00"
          PLAN_BANDWIDTH: "1.15 TiB"
          PLAN_MINUTES: "400.0k"
          PLAN_STORAGE: "125.00 GiB"
          USAGE_BANDWIDTH: "1.00 TiB"
          USAGE_MINUTES: "123.0k"
          BROADCAST_PLAN: "Basic ($100 / month) and Pro ($500 / month)"
          PEER_PLAN: "Business ($2,000 / month)"
          USAGE_STORAGE: "2.00 GiB"
        expect(mergeVars.templateVars).to.deep.equal(expectedMergeVars)
        assertMergeVarsInVars(mergeVars, expectedMergeVars)

      it 'sends the billing email', (done)->
        accountMailer.monthlyBill @account, @abh, @abh.history[0]._id, @now, (err, response)=>
          options = getMailOptions.call(this)
          expect(options.subject).to.equal("Your cine.io invoice")
          assertToAccount(options, @account)
          assertCorrectMergeVars accountMergeVars(options, @account), @now
          assertMailSent.call(this, err, response, done)

    describe 'without peer', ->
      beforeEach (done)->
        results =
          billing:
            plan: 500
            bandwidthOverage: 0
            storageOverage: 0
          usage:
            bandwidth: humanizeBytes.TiB
            storage: humanizeBytes.GiB * 2
            peerMilliseconds: 0
            bandwidthOverage: humanizeBytes.Gib * 5
            storageOverage: humanizeBytes.Gib * 2
        @now = new Date
        @abh = new AccountBillingHistory(_account: @account._id)
        @abh.history.push
          stripeChargeId: 'this month charge'
          billingDate: @now
          billedAt: new Date
          details: results
          accountPlans: @account.productPlans
          paid: true

        lastMonth = new Date
        lastMonth.setDate(1)
        lastMonth.setMonth(lastMonth.getMonth() - 1)
        @abh.history.push
          billingDate: lastMonth
          stripeChargeId: 'last month charge'
          paid: true
        @abh.save done

      assertCorrectMergeVars = (mergeVars, billingMonthDate)->
        month = moment(billingMonthDate).format("MMM YYYY")
        expectedMergeVars =
          header_blurb: "Thank you for using cine.io."
          ACCOUNT_NAME: "my account name"
          BILLING_MONTH: month
          BILL_TOTAL: "$5.00"
          PLAN_BANDWIDTH: "1.15 TiB"
          PLAN_MINUTES: ""
          PLAN_STORAGE: "125.00 GiB"
          USAGE_BANDWIDTH: "1.00 TiB"
          USAGE_MINUTES: ""
          BROADCAST_PLAN: "Basic ($100 / month) and Pro ($500 / month)"
          PEER_PLAN: undefined
          USAGE_STORAGE: "2.00 GiB"
        expect(mergeVars.templateVars).to.deep.equal(expectedMergeVars)
        assertMergeVarsInVars(mergeVars, expectedMergeVars)

      beforeEach (done)->
        @account.productPlans = {broadcast: ['basic', 'pro'], peer: []}
        @account.save done

      it 'sends the billing email', (done)->
        accountMailer.monthlyBill @account, @abh, @abh.history[0]._id, @now, (err, response)=>
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
        accountPlans: @account.productPlans

      lastMonth = new Date
      lastMonth.setDate(1)
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

    beforeEach (done)->
      @throttledDate  = new Date
      @throttledDate.setDate(@throttledDate.getDate() + 10)
      @account.throttledAt = @throttledDate
      @account.save done

    assertCorrectMergeVars = (mergeVars, expectedReasonString)->

      expectedMergeVars =
        header_blurb: "Please update your account"
        name: "my account name"

      throttledDate = moment(@throttledDate).format("MMMM Do, YYYY")
      expect(mergeVars.templateVars.content).to.include("on <strong>#{throttledDate}</strong> your account will be disabled.")
      expect(mergeVars.templateVars.content).to.include(expectedReasonString)
      expect(mergeVars.templateVars.content).to.include("All API requests will begin returning a 402 response.")
      expect(mergeVars.templateVars.content).to.include("Please update your account at <a href=\"https://www.cine.io/account\">https://www.cine.io/account</a>.")
      # content is huge, don't want to include it here
      expectedMergeVars.content = mergeVars.templateVars.content

      expect(mergeVars.templateVars).to.deep.equal(expectedMergeVars)
      assertMergeVarsInVars(mergeVars, expectedMergeVars)

    it 'requires a reason', (done)->
      accountMailer.throttledAccount @account, (err, response)->
        expect(err).to.equal("Not a valid reason")
        done()

    it 'sends a throttled account email for accounts over limit', (done)->
      @account.throttledReason = 'overLimit'
      accountMailer.throttledAccount @account, (err, response)=>
        options = getMailOptions.call(this)
        expect(options.subject).to.equal("Your account has been disabled (usage exceeded).")
        assertToAccount(options, @account)
        assertCorrectMergeVars.call this, accountMergeVars(options, @account), "you've exceeded the usage limits of your current plan."
        assertMailSent.call(this, err, response, done)

    it 'sends a throttled account email for accounts with a declined charge', (done)->
      @account.throttledReason = 'cardDeclined'
      accountMailer.throttledAccount @account, (err, response)=>
        options = getMailOptions.call(this)
        expect(options.subject).to.equal("Your card was declined. Account at risk of being disabled.")
        assertToAccount(options, @account)
        assertCorrectMergeVars.call this, accountMergeVars(options, @account), "we were unable to charge your current card."
        assertMailSent.call(this, err, response, done)
