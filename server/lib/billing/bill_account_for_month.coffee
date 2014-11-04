_ = require('underscore')
stripe = require('stripe')(Cine.config('variables/stripe').secretKey)
calculateAccountBill = Cine.server_lib("billing/calculate_account_bill.coffee")
AccountBillingHistory = Cine.server_model("account_billing_history")
mailer = Cine.server_lib("mailer")
humanizeBytes = Cine.lib('humanize_bytes')
AccountThrottler = Cine.server_lib('account_throttler')

CARD_DECLINED_ERROR = 'Error: Your card was declined.'
ALREADY_REFUNDED_REGEX = /Charge ch_\S+ has already been refunded./
handleCardDeclined = (account, abh, monthToBill, callback)->
  # mailer.cardDeclined(account, abh, monthToBill)
  mailer.admin.cardDeclined(account, abh, monthToBill)
  throttleInFourDays = new Date
  throttleInFourDays.setDate(throttleInFourDays.getDate() + 4)
  AccountThrottler.throttle account, 'cardDeclined', throttleInFourDays, (err)->
    return callback(err) if err
    mailer.admin.throttledAccount account
    mailer.throttledAccount account, callback

emailUnknownError = (account, abh, monthToBill)->
  mailer.admin.unknownChargeError(account, abh, monthToBill)

findOrCreateAccountBillingHistory = (account, callback)->
  AccountBillingHistory.findOne _account: account._id, (err, abh)->
    return callback(err) if err
    return callback(null, abh) if abh
    abh = new AccountBillingHistory(_account: account._id)
    abh.save callback

saveResultsToRecord = (abh, account, monthToBill, results, callback)->
  record =
    billingDate: monthToBill
    billedAt: new Date
    details: results
    accountPlans: account.plans
  abh.history.push record
  abh.save callback

findPrimaryCard = (account)->
  _.findWhere account.stripeCustomer.cards, deletedAt: undefined

chargeStripe = (account, results, callback)->
  amount = results.billing.plan + results.billing.bandwidthOverage + results.billing.storageOverage
  console.log("charging stripe for account", account._id, amount)
  stripeData =
    amount: Math.floor(amount)
    currency: "USD"
    customer: account.stripeCustomer.stripeCustomerId
    card: findPrimaryCard(account).stripeCardId
    capture: true
  stripe.charges.create stripeData, callback

saveNewCharge = (abh, monthToBill, stripeResults, callback)->
  record = abh.billingRecordForMonth(monthToBill)
  record.stripeChargeId = stripeResults.id
  record.paid = stripeResults.paid
  abh.save callback

sendEmailReceipt = (account, abh, monthToBill, callback)->
  mailer.monthlyBill account, abh, monthToBill, (err, emailResult)->
    # console.log("sent email", err, emailResult)
    record = abh.billingRecordForMonth(monthToBill)
    record.mandrillEmailId = emailResult[0]._id
    abh.save callback

saveChargeError = (account, abh, monthToBill, chargeError, callback)->
  record = abh.billingRecordForMonth(monthToBill)
  record.paid = false
  record.chargeError = chargeError

  abh.save (err)->
    return callback(err) if err
    if record.chargeError == CARD_DECLINED_ERROR
      handleCardDeclined(account, abh, monthToBill, callback)
    else
      emailUnknownError(account, abh, monthToBill)
      callback()

chargeAccount = (account, abh, monthToBill, results, callback)->
  return callback("account not stripe customer") unless account.stripeCustomer.stripeCustomerId
  return callback("account has no primary card") unless findPrimaryCard(account)
  chargeStripe account, results, (err, stripeResults)->
    if err
      return saveChargeError account, abh, monthToBill, err, (err2)->
        return callback(err2)
    saveNewCharge abh, monthToBill, stripeResults, (err)->
      return callback(err) if err

      sendEmailReceipt account, abh, monthToBill, callback

sendNotBilledEmail = (account, abh, monthToBill, callback)->
  record = abh.billingRecordForMonth(monthToBill)
  record.notCharged = true
  abh.save (err)->
    return callback(err) if err
    mailer.underOneGibBill account, abh, monthToBill, (err, emailResult)->
      record = abh.billingRecordForMonth(monthToBill)
      record.mandrillEmailId = emailResult[0]._id
      abh.save callback

shouldBill = (account, results)->
  return true if account.stripeCustomer.stripeCustomerId && findPrimaryCard(account)
  results.usage.bandwidth > humanizeBytes.GiB && results.usage.storage > humanizeBytes.GiB

# provides a nice api
module.exports = (account, monthToBill, callback)->
  module.exports.__work(account, monthToBill, callback)

# spyable function
module.exports.__work = (account, monthToBill, callback)->
  return callback("can only charge cine.io accounts") if account.billingProvider != 'cine.io'
  # console.log("charging account", account)
  return callback(null, "free accounts do not recieve non-invoice emails") if calculateAccountBill.accountPlanAmount(account) == 0
  findOrCreateAccountBillingHistory account, (err, abh)->
    return callback(err) if err
    return callback(null, "already charged account for this month") if abh.hasBilledForMonth(monthToBill)
    calculateAccountBill account, monthToBill, (err, results)->
      return callback(err) if err
      # console.log("calculated", err, results)
      saveResultsToRecord abh, account, monthToBill, results, (err)->
        # console.log("saved results to record", err)
        return callback(err) if err

        if shouldBill(account, results)
          console.log("will bill account", account._id, account.billingEmail)
          chargeAccount(account, abh, monthToBill, results, callback)
        else
          console.log("will not bill account", account._id, account.billingEmail)
          sendNotBilledEmail(account, abh, monthToBill, callback)
