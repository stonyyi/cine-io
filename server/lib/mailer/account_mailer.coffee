domain = Cine.config('variables/mailer_domain')
getMailerLogo = Cine.server_lib('mailer/get_mailer_logo')
sendTemplateEmail = Cine.server_lib('mailer/send_template_email')
_ = require('underscore')
_str = require('underscore.string')
humanizeBytes = Cine.lib('humanize_bytes')
humanizeNumber = Cine.lib('humanize_number')
moment = require('moment')
BackboneAccount = Cine.model('account')
UsageReport = Cine.model('usage_report')
calculateAccountBill = Cine.server_lib("billing/calculate_account_bill.coffee")
ProvidersAndPlans = Cine.config("providers_and_plans")
fullCurrentUserJson = Cine.server_lib('full_current_user_json')

noop = ->

ENJOY_AND_QUESTIONS = """
<p>We hope you enjoy using <a href="https://www.cine.io">cine.io</a>. If you have any questions you can reply to this email, or send us an email at <a href="mailto:support@cine.io">support@cine.io</a>.</p>
"""

sendMail = (mailOptions, callback)->
  getMailerLogo (err, logoImageData)->
    images = []
    images.push type: "image/png", name: "LOGO_IMAGE", content: logoImageData if !err and logoImageData
    mailOptions.images = images

    sendTemplateEmail.send mailOptions, callback

exports.forgotPassword = (user, passwordChangeRequest, callback=noop)->
  actionUrl = "https://#{domain}/recover-password/#{passwordChangeRequest.identifier}"
  mailOptions =
    templateName: 'simple-user-action-link'
    subject: 'Reset your password'
    toEmail: user.email
    toName: user.name
    userTemplateVars:
      header_blurb: 'Reset your password'
      name: user.name
      lead_copy: "<p>Someone recently requested that the password be reset for #{user.email}.</p>"
      action_copy: "Click here to reset your password."
      action_url: actionUrl
      followup_copy: "<p>If this is a mistake just ignore this email &mdash; your password will not be changed.</p>"
  sendMail mailOptions, callback

# input: ['basic', 'solo']
# Basic and Solo
accountPlans = (plans, product)->
  plans = plans[product]
  return undefined unless plans.length # don't want to return empty string
  planStrings = _.map plans, (plan)->
    planName = _str.titleize(plan)
    planCost = ProvidersAndPlans['cine.io'][product].plans[plan].price
    "#{planName} ($#{humanizeNumber(planCost)} / month)"
  _str.toSentence(planStrings)

displayCurrency = (amountInCents)->
  amountInDollars = amountInCents / 100
  withDecimals = amountInDollars.toFixed(2)
  value = if withDecimals == amountInDollars
    amountInDollars
  else
    withDecimals
  "$#{value}"

THOUSAND = 1000
MINUTES = 60 * THOUSAND # milliseconds
humanizeMinutes = (milliseconds)->
  return "" unless milliseconds
  if milliseconds > (1 * THOUSAND * MINUTES)
    number = humanizeNumber(milliseconds / (1 * THOUSAND * MINUTES), 1)
    "#{number}k"
  else
    "#{humanizeNumber(milliseconds / MINUTES, 2)}"

exports.monthlyBill = (account, accountBillingHistory, recordId, billingMonthDate, callback=noop)->
  record = accountBillingHistory.history.id(recordId)
  name = account.name || account.billingEmail
  usage = record.details.usage
  billing = record.details.billing
  fullCurrentUserJson.accountJson account, (err, accountJSON)->
    return callback(err) if err
    backboneAccount = new BackboneAccount(accountJSON)

    mailOptions =
      templateName: 'monthly-invoice'
      subject: 'Your cine.io invoice'
      toEmail: account.billingEmail
      toName: name
      userTemplateVars:
        header_blurb: 'Thank you for using cine.io.'
        BILLING_MONTH: moment(billingMonthDate).format("MMM YYYY")
        ACCOUNT_NAME: name
        BROADCAST_PLAN: accountPlans(record.accountPlans, 'broadcast')
        PEER_PLAN: accountPlans(record.accountPlans, 'peer')
        # Plan details
        PLAN_BANDWIDTH: humanizeBytes(UsageReport.maxUsagePerAccount(backboneAccount, 'bandwidth', 'broadcast'))
        PLAN_STORAGE: humanizeBytes(UsageReport.maxUsagePerAccount(backboneAccount, 'storage', 'broadcast'))
        PLAN_MINUTES: humanizeMinutes(UsageReport.maxUsagePerAccount(backboneAccount, 'minutes', 'peer'))
        # Monthly Usage
        USAGE_BANDWIDTH: humanizeBytes(usage.bandwidth)
        USAGE_STORAGE: humanizeBytes(usage.storage)
        USAGE_MINUTES: humanizeMinutes(usage.peerMilliseconds)
        # TOTAL
        BILL_TOTAL: displayCurrency(billing.plan)

    sendMail mailOptions, callback

exports.underOneGibBill = (account, accountBillingHistory, billingMonthDate, callback=noop)->
  name = account.name || account.billingEmail
  month = moment(billingMonthDate).format("MMM YYYY")
  mailOptions =
    templateName: 'blank-with-header-and-footer'
    subject: 'Your non-invoice for cine.io.'
    toEmail: account.billingEmail
    toName: name
    userTemplateVars:
      header_blurb: "Have #{month} on us."
      name: name
      content: """
      <p>This is normally when bills come around. Your bandwidth usage was under 1 GiB so have #{month} on us.</p>
      <p>We hope you enjoy using <a href="https://www.cine.io">cine.io</a>.</p>
      <p>Regards,<br/>
      Thomas Shafer<br/>
      Technical Officer, cine.io</p>
      """
  sendMail mailOptions, callback

exports.automaticallyUpgradedAccount = (account, oldPlans, callback=noop)->
  oldBroadcastPlan = oldPlans.broadcast
  oldPeerPlan = oldPlans.peer
  name = account.name || account.billingEmail
  if oldPeerPlan
    newPlan = _.first account.productPlans.peer
  else
    newPlan = _.first account.productPlans.broadcast
  mailOptions =
    templateName: 'blank-with-header-and-footer'
    subject: 'Account upgraded your cine.io account plan based on usage.'
    toEmail: account.billingEmail
    toName: name
    userTemplateVars:
      header_blurb: "Account upgraded to #{newPlan}."
      name: name
      content: """
      <p>We want to let you know that your account has exceeded the plan usage. We have upgraded your account to #{newPlan}.</p>
      #{ENJOY_AND_QUESTIONS}
      <p>Regards,<br/>
      Thomas Shafer<br/>
      Technical Officer, cine.io</p>
      """
  sendMail mailOptions, callback

exports.willUpgradeAccount = (account, newPlan, callback=noop)->
  name = account.name || account.billingEmail
  mailOptions =
    templateName: 'blank-with-header-and-footer'
    subject: 'Account reaching usage limit.'
    toEmail: account.billingEmail
    toName: name
    userTemplateVars:
      header_blurb: "Account reaching usage limit."
      name: name
      content: """
      <p>We want to let you know that your account is approaching the monthly usage limit. If this happens we will automatically upgrade your account to #{newPlan}.</p>
      #{ENJOY_AND_QUESTIONS}
      <p>Regards,<br/>
      Thomas Shafer<br/>
      Technical Officer, cine.io</p>
      """
  sendMail mailOptions, callback

placetoUpgradeYourAccount = (account)->
  return account.appdirectData.marketplace.baseUrl if account.billingProvider == 'appdirect'
  returnUrl =
    heroku: ProvidersAndPlans['heroku'].url
    engineyard: ProvidersAndPlans['engineyard'].url
    'cine.io': "https://www.cine.io/account"
  returnUrl[account.billingProvider]

throttleReason = (reason)->
  reasons =
    overLimit: "The reason we've disabled your account is because you've exceeded the usage limits of your current plan."
    cardDeclined: "The reason we've disabled your account is because we were unable to charge your current card."
  reasons[reason]

throttleSubject = (reason)->
  reasons =
    overLimit: 'Your account has been disabled (usage exceeded).'
    cardDeclined: 'Your card was declined. Account at risk of being disabled.'
  reasons[reason]

exports.throttledAccount = (account, callback=noop)->
  name = account.name || account.billingEmail
  throttleDate = moment(account.throttledAt).format("MMMM Do, YYYY")
  throttledReason = throttleReason(account.throttledReason)
  unless throttledReason
    return process.nextTick -> callback("Not a valid reason")
  fullCurrentUserJson.accountJson account, (err, accountJSON)->
    return callback(err) if err
    backboneAccount = new BackboneAccount(accountJSON)

    urlToUpgrade = backboneAccount.updateAccountUrl()
    mailOptions =
      templateName: 'blank-with-header-and-footer'
      subject: throttleSubject(account.throttledReason)
      toEmail: account.billingEmail
      toName: name
      userTemplateVars:
        header_blurb: "Please update your account"
        name: name
        content: """
        <p>We wanted to let you know on <strong>#{throttleDate}</strong> your account will be disabled. All API requests will begin returning a 402 response. #{throttledReason} Please update your account at <a href="#{urlToUpgrade}">#{urlToUpgrade}</a>.</p>
        #{ENJOY_AND_QUESTIONS}
        <p>Regards,<br/>
        Thomas Shafer<br/>
        Technical Officer, cine.io</p>
        """
    sendMail mailOptions, callback

exports.welcomeEmail = (user, callback=noop)->
  name = user.name || user.email
  mailOptions =
    templateName: 'blank-with-header-and-footer'
    subject: 'Welcome to cine.io.'
    toEmail: user.email
    toName: name
    userTemplateVars:
      header_blurb: 'Welcome to cine.io.'
      name: name
      content: """
      <p>Welcome to <a href='https://www.cine.io'>cine.io</a>!</p>
      <p>All of our APIs and common workflows are documented on our <a href='http://developer.cine.io/'>documentation page</a>.</p>
      <p>We have a <a href="https://github.com/cine-io/broadcast-js-sdk">JavaScript SDK</a>, <a href="https://github.com/cine-io/cineio-broadcast-ios">iOS pod</a>, and <a href="https://github.com/cine-io/cineio-broadcast-android">Android package</a> for easy playing and publishing live streams.</p>
      <p>We have a <a href="https://github.com/cine-io/peer-js-sdk">JavaScript SDK</a> and <a href="https://github.com/cine-io/cineio-peer-android">Android package</a> for easy real time video chat. We can also broadcast your WebRTC streams to cine.io rtmp/hls live streams.</p>
      <br/>
      <p>We have server side packages for <a href="https://github.com/cine-io/cineio-ruby">ruby</a>, <a href="https://github.com/cine-io/cineio-node">node</a>, and <a href="https://github.com/cine-io/cineio-python">python</a>.</p>
      <br/>
      <p>All of our repositories and some sample apps can be found on our <a href="http://git.cine.io">Github page</a>.</p>
      <br/>
      <p>#{ENJOY_AND_QUESTIONS}</p>
      <p>Happy Coding.</p>
      <p>Regards,<br/>
      Thomas Shafer<br/>
      Technical Officer, cine.io</p>
      """
  sendMail mailOptions, callback
