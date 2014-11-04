Account = Cine.server_model('account')
require "mongoose-querystream-worker"
chargeAccountForMonth = Cine.server_lib('billing/charge_account_for_month')

# this is expecting to run on the first of every month
module.exports = (done)->
  # I know this is weird, but I can stub Date.now and not `new Date`
  monthToBill = new Date(Date.now())
  return done("Not running on the first of the month") unless monthToBill.getDate() == 1
  monthToBill.setDate(monthToBill.getDate() - 1) # run for the previous month

  billAcount = (account, callback)->
    # console.log("billing account", account)
    chargeAccountForMonth account, monthToBill, callback

  scope = Account.where(billingProvider: 'cine.io').exists('deletedAt', false).exists('throttledAt', false)
  scope.stream().concurrency(20).work billAcount, done
