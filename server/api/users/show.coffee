getUser = Cine.server_lib('get_user')
fullCurrentUserJson = Cine.server_lib('full_current_user_json')

Show = (params, callback)->
  getUser params, (err, user, options)->
    return callback(err, user, options) if err
    fullCurrentUserJson user, (err, userJson)->
      return callback(err, userJson)

module.exports = Show
