getHerokuAccountDetails = Cine.server_lib('get_heroku_account_details')
Account = Cine.server_model('account')

# payload:
#  accountId: id for an Account model
module.exports = (payload, callback)->
  return callback("accountId not passed in") unless payload && payload.accountId
  accountId = payload.accountId

  Account.findById accountId, (err, account)->
    return callback(err) if err
    return callback("account not found for id: #{accountId}") unless account
    getHerokuAccountDetails account, (err, details)->
      return callback(err) if err
      account.billingEmail = details.owner_email
      account.herokuData = details
      console.log("setting heroku data", account, details)
      account.save callback
