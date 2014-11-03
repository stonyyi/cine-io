async = require('async')
Project = Cine.server_model('project')

exports.throttle = (account, throttledReason, throttleDate, callback)->
  if typeof throttleDate == 'function'
    callback = throttleDate
    throttleDate = new Date
  asyncCalls =
    updateAccount: (callback)->
      account.throttledAt = throttleDate
      account.throttledReason = throttledReason
      # this strips the numAffected
      account.save (err, account)->
        callback(err, account)
    updateProjects: (callback)->
      conditions = _account: account._id
      update = $set: { throttledAt: throttleDate }
      options = multi: true
      Project.update(conditions, update, options, callback)

  async.parallel asyncCalls, (err, results)->
    return callback(err) if err
    callback(null, results.updateAccount)

exports.unthrottle = (account, callback)->
  asyncCalls =
    updateAccount: (callback)->
      account.throttledAt = undefined
      account.throttledReason = undefined
      # this strips the numAffected
      account.save (err, account)->
        callback(err, account)
    updateProjects: (callback)->
      conditions = _account: account._id
      update = $unset: { throttledAt: 1 }
      options = multi: true
      Project.update(conditions, update, options, callback)

  async.parallel asyncCalls, (err, results)->
    return callback(err) if err
    callback(null, results.updateAccount)
