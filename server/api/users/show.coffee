getUser = Cine.server_lib('get_user')

Show = (params, callback)->
  getUser params, (err, user, options)->
    return callback(err, user) if err
    return callback(null, user.simpleCurrentUserJSON())

module.exports = Show
