updateUser = Cine.api('users/update')
module.exports = (params, callback) ->
  return callback("not logged in", null, status: 401) unless params.sessionUserId
  params._id = params.sessionUserId
  updateUser.doUpdate(params, callback)
