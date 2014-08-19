# TODO DEPRECATED: does way different things
async = require('async')

module.exports = (user, callback)->
  asyncCalls =
    deleteUser: (callback)->
      user.deletedAt = new Date
      # save returns more than err, user
      # but we only want to return user
      user.save (err, user)->
        callback(err, user)

  async.parallel asyncCalls, (err, results)->
    callback(err, results.deleteUser)
