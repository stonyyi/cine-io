deleteAccount = Cine.server_lib('delete_account')
getAccount = Cine.server_lib('get_account')
fullCurrentUserJson = Cine.server_lib('full_current_user_json')

module.exports = (params, callback)->
  getAccount params, (err, account, options)->
    return callback(err, account, options) if err
    return callback('cannot delete non cine.io accounts', null, status: 400) unless account.billingProvider == 'cine.io'
    deleteAccount account, (err, deletedAccount)->
      return callback(err, null, status: 400) if err
      fullCurrentUserJson.accountJson account, (err, accountJSON)->
        accountJSON.deletedAt = deletedAccount.deletedAt
        callback null, accountJSON
