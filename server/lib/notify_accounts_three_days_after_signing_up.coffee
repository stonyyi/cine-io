debug = require('debug')('cine:notify_accounts_three_days_after_signing_up')
mailer = Cine.server_lib('mailer')
require "mongoose-querystream-worker"
Account = Cine.server_model('account')
checkKeenStatus = Cine.server_lib('reporting/check_keen_io_status')
calculateAccountUsage = Cine.server_lib('reporting/calculate_account_usage')
fetchAllProjectsPeerMilliseconds = Cine.server_lib('reporting/peer/fetch_all_projects_peer_milliseconds')
AccountEmailHistory = Cine.server_model("account_email_history")

daysAgoAtMidnight = (daysAgo)->
  d = new Date
  d.setHours(0)
  d.setMinutes(0)
  d.setSeconds(0)
  d.setMilliseconds(0)
  d.setDate(d.getDate() - daysAgo)
  d

ACCOUNT_EMAIL_HISTORY_KIND = 'threeDayNotification'

sendEmailUnlessAlreadyReceived = (account, aeh, emailFunctionName, callback)->
  mailer[emailFunctionName] account, (err)->
    return callback(err) if err
    aeh.history.push
      kind: ACCOUNT_EMAIL_HISTORY_KIND
      sentAt: new Date
    aeh.save callback

sendDidBandwidth = (account, aeh, callback)->
  debug("sendDidBandwidth", account._id)
  sendEmailUnlessAlreadyReceived account, aeh, 'didSendBandwidth', callback

sendDidPeer = (account, aeh, callback)->
  debug("sendDidPeer", account._id)
  sendEmailUnlessAlreadyReceived account, aeh, 'didSendPeer', callback

sendDidNothingEmail = (account, aeh, callback)->
  debug("sendDidNothingEmail", account._id)
  sendEmailUnlessAlreadyReceived account, aeh, 'haventDoneAnything', callback

module.exports = (done)->
  threeDaysAgo = daysAgoAtMidnight(3)
  twoDaysAgo = daysAgoAtMidnight(2)
  month = threeDaysAgo

  checkKeenStatus (err)->
    return done(err) if err
    actions =
      didSendBandwidth: []
      didSendPeer: []
      didNothing: []
      unknown: []
    debug("fetching keen peer milliseconds")
    fetchAllProjectsPeerMilliseconds.between threeDaysAgo, twoDaysAgo, (err, projectIdToPeerMilliseconds)->
      debug("fetched keen peer milliseconds", err)
      return done(err) if err

      sendThankYouEmail = (account, callback)->
        AccountEmailHistory.findOrCreate _account: account._id, (err, aeh)->
          return callback(err) if err
          return callback() if aeh.findKind(ACCOUNT_EMAIL_HISTORY_KIND)

          calculateAccountUsage.byMonthWithKeenMilliseconds account, month, projectIdToPeerMilliseconds, (err, result)->
            return callback(err) if err
            didBandwidth = result.bandwidth > 0
            didPeer = result.peerMilliseconds > 0
            didNothing = result.bandwidth == 0 && result.storage == 0 && result.peerMilliseconds == 0
            if didBandwidth
              actions.didSendBandwidth.push(account._id)
              sendDidBandwidth(account, aeh, callback)
            else if didPeer
              actions.didSendPeer.push(account._id)
              sendDidPeer(account, aeh, callback)
            else if didNothing
              actions.didNothing.push(account._id)
              return sendDidNothingEmail(account, aeh, callback)
            else
              actions.unknown.push(account._id)
              callback()

      endFunction = (err)->
        debug("done processing all accounts", err)
        done(err, actions)

      createdExactlyThreeDaysAgo =
        createdAt:
          $gte: threeDaysAgo
          $lt: twoDaysAgo
      scope = Account.where(createdExactlyThreeDaysAgo).exists('deletedAt', false).exists('throttledAt', false)
      scope.stream().concurrency(20).work sendThankYouEmail, endFunction
