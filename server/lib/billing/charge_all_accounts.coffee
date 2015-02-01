_ = require('underscore')
Account = Cine.server_model('account')
require "mongoose-querystream-worker"
chargeAccountForMonth = Cine.server_lib('billing/charge_account_for_month')
mailer = Cine.server_lib('mailer')

# this is expecting to run on the first of every month
module.exports = (done)->
  # I know this is weird, but I can stub Date.now and not `new Date`
  monthToBill = new Date(Date.now())
  return done("Not running on the first of the month") unless monthToBill.getDate() == 1
  monthToBill.setDate(monthToBill.getDate() - 1) # run for the previous month
  accountErrs = {}
  billed = {}
  billAcount = (account, callback)->
    # console.log("billing account", account)
    chargeAccountForMonth account, monthToBill, (err, data)->
      accountErrs[account._id.toString()] = err if err
      billed[account._id.toString()] = data.results if data && data.results
      callback()

  scope = Account.where(billingProvider: 'cine.io').exists('deletedAt', false).exists('throttledAt', false)
  scope.stream().concurrency(20).work billAcount, (err)->
    mailer.admin.chargedAllAccounts(err: err, accountErrs: accountErrs, billed: billed)
    return done(err: err, accountErrs: accountErrs) if err || !_.isEmpty(accountErrs)
    done()
