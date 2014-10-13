_ = require('underscore')
stripe = require('stripe')(Cine.config('variables/stripe').secretKey)
calculateAccountBill = Cine.server_lib("billing/calculate_account_bill.coffee")
AccountBillingHistory = Cine.server_model("account_billing_history")
mailer = Cine.server_lib("mailer")

CARD_DECLINED_ERROR = 'Error: Your card was declined.'
ALREADY_REFUNDED_REGEX = /Charge ch_\S+ has already been refunded./
emailCardDeclined = (account, abh, now)->
  # mailer.cardDeclined(account, abh, now)
  mailer.admin.cardDeclined(account, abh, now)

emailUnknownError = (account, abh, now)->
  mailer.admin.unknownChargeError(account, abh, now)

findOrCreateAccountBillingHistory = (account, callback)->
  AccountBillingHistory.findOne _account: account._id, (err, abh)->
    return callback(err) if err
    return callback(null, abh) if abh
    abh = new AccountBillingHistory(_account: account._id)
    abh.save callback

saveResultsToRecord = (abh, account, now, results, callback)->
  record =
    billingDate: now
    billedAt: new Date
    details: results
    accountPlans: account.plans
  abh.history.push record
  abh.save callback

findPrimaryCard = (account)->
  _.findWhere account.stripeCustomer.cards, deletedAt: undefined

chargeStripe = (account, results, callback)->
  amount = results.billing.plan + results.billing.bandwidthOverage + results.billing.storageOverage
  stripeData =
    amount: amount
    currency: "USD"
    customer: account.stripeCustomer.stripeCustomerId
    card: findPrimaryCard(account).stripeCardId
    capture: true
  stripe.charges.create stripeData, callback

saveNewCharge = (abh, now, stripeResults, callback)->
  record = abh.billingRecordForMonth(now)
  record.stripeChargeId = stripeResults.id
  record.paid = stripeResults.paid
  abh.save callback

sendEmailReceipt = (account, abh, now, callback)->
  mailer.monthlyBill account, abh, now, (err, emailResult)->
    # console.log("sent email", err, emailResult)
    record = abh.billingRecordForMonth(now)
    record.mandrillEmailId = emailResult[0]._id
    abh.save callback

saveChargeError = (account, abh, now, chargeError, callback)->
  record = abh.billingRecordForMonth(now)
  record.paid = false
  record.chargeError = chargeError

  if record.chargeError == CARD_DECLINED_ERROR
    emailCardDeclined(account, abh, now)
  else
    emailUnknownError(account, abh, now)

  abh.save callback

module.exports = (account, now, callback)->
  # console.log("charging account", account)
  return callback("account not stripe customer") unless account.stripeCustomer.stripeCustomerId
  return callback("account has no primary card") unless findPrimaryCard(account)
  findOrCreateAccountBillingHistory account, (err, abh)->
    return callback(err) if err
    return callback("already charged account for this month") if abh.hasBilledForMonth(now)
    calculateAccountBill account, (err, results)->
      # console.log("calculated", err, results)
      return callback(err) if err
      saveResultsToRecord abh, account, now, results, (err)->
        # console.log("saved results to record", err)
        return callback(err) if err
        chargeStripe account, results, (err, stripeResults)->
          if err
            return saveChargeError account, abh, now, err, (err2)->
              return callback(err2)
          saveNewCharge abh, now, stripeResults, (err)->
            return callback(err) if err
            sendEmailReceipt account, abh, now, callback
