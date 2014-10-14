environment = require('../config/environment')
Cine.config('connect_to_mongo')

throttleAccountsWhoCannotPayForOverages = Cine.server_lib('throttle_accounts_who_cannot_pay_for_overages')

throttleAccountsWhoCannotPayForOverages (err)->
  console.log(err)
  process.nextTick process.exit
