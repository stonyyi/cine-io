User = Cine.server_model('user')
Account = Cine.server_model('account')
_str = require 'underscore.string'
TextMongooseErrorMessage = Cine.server_lib('text_mongoose_error_message')
mailer = Cine.server_lib('mailer')
fullCurrentUserJson = Cine.server_lib('full_current_user_json')

updateUser = (params, callback)->
  return callback("not logged in", null, status: 401) unless params.sessionUserId
  return callback("id required", null, status: 400) unless params.id
  # can update user if the user is the logged in user
  return updateUser.doUpdate(params, callback) if params.sessionUserId.toString() == params.id.toString()
  # otherwise check for site admin privleges
  return callback("unauthorized", null, status: 401)
  throw new Error("site admin not implemented yet")

updateAccountName = (user, callback)->
  return callback() if user._accounts.length == 0
  Account.findById user._accounts[0], (err, account)->
    return callback() if err || !account
    return callback() if account.name
    account.name = user.name
    account.save callback

updateUser.doUpdate = (params, callback)->
  User.findById params.id, (err, user)->
    return callback(err, null, status: 400) if err
    return callback("not found", null, status: 404) unless user

    user.name = params.name unless _str.isBlank(params.name)
    user.email = params.email unless _str.isBlank(params.email)
    user.save (err)->
      return callback(TextMongooseErrorMessage(err), null, status: 400) if err
      done = ->
        fullCurrentUserJson user, (err, fullCurrentUserJson)->
          callback(err, fullCurrentUserJson)
      if params.completedsignup
        mailer.welcomeEmail(user)
        mailer.admin.newUser(user, params.completedsignup)
        updateAccountName user, done
      else
        done()
module.exports = updateUser
