User = Cine.server_model 'user'
PasswordChangeRequest = Cine.server_model 'password_change_request'
mailer = Cine.server_lib("mailer")

module.exports = (params, callback) ->
  return callback("email required", null, status: 400) unless params.email

  User.findOne email: params.email, (err, user)->
    return callback(err, null, status: 400) if err
    return callback("not found", null, status: 404) unless user

    pcr = new PasswordChangeRequest(_user: user.id)
    pcr.save (err)->
      return callback(err, null, status: 400) if err
      mailer.forgotPassword(user, pcr)
      callback(null, {})
