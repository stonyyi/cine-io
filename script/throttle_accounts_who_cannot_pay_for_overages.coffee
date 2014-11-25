environment = require('../config/environment')
Cine.config('connect_to_mongo')

updateOrThrottleAccountsWhoCannotPayForOverages = Cine.server_lib('billing/update_or_throttle_accounts_who_cannot_pay_for_overages')

updateOrThrottleAccountsWhoCannotPayForOverages (err)->
  console.log(err)
  process.nextTick process.exit
