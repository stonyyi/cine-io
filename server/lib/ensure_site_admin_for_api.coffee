User = Cine.server_model('user')

ensureSiteAdmin = (params, callback)->
  return callback(false) unless params.sessionUserId
  User.findById params.sessionUserId, (err, user)->
    return callback(false) if err || !user
    return callback(user.isSiteAdmin)

ensureSiteAdmin.unauthorizedCallback = (callback)->
  callback("Unauthorized", null, status: 401)

module.exports = ensureSiteAdmin
