debug = require('debug')('cine:charge_all_accounts_if_on_the_first_of_the_month')
chargeAllAccounts = Cine.server_lib('billing/charge_all_accounts')

# this is expecting to run on the first of every month
module.exports = (done)->
  # I know this is weird, but I can stub Date.now and not `new Date`
  monthToBill = new Date(Date.now())
  return done() unless monthToBill.getDate() == 1
  debug("it's the first of the month, charge 'em", monthToBill)
  chargeAllAccounts done
