# heroku run --app=cine-io coffee scripe/delete_account ACCOUNT_ID
environment = require('../config/environment')
Cine.config('connect_to_mongo')
Account = Cine.server_model('account')
deleteAccount = Cine.server_lib('delete_account')

endFunction = (err)->
  console.log('the end', err)
  process.exit(0)

accountId = process.argv[2]

Account.findById accountId, (err, account)->
  return endFunction(err) if err
  console.log("deleting account", account.id, account.billingEmail)
  deleteAccount account, endFunction
