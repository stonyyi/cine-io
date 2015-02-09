Project = Cine.server_model('project')
CalculateProjectPeerMilliseconds = Cine.server_lib('reporting/peer/calculate_project_peer_milliseconds')
async = require('async')

exports.byMonth = (account, month, callback)->

  calculateProjectUsage = (accum, project, callback)->
    CalculateProjectPeerMilliseconds.byMonth project._id, month, (err, projectPeerMilliseconds)->
      return callback(err) if err
      callback(null, accum + projectPeerMilliseconds)

  account.projects (err, projects)->
    async.reduce projects, 0, calculateProjectUsage, callback

exports.byMonthWithKeenMilliseconds = (account, month, projectIdToPeerMilliseconds, callback)->
  calculateProjectUsage = (accum, project, callback)->
    projectPeerMilliseconds = projectIdToPeerMilliseconds[project._id.toString()] || 0
    callback(null, accum + projectPeerMilliseconds)

  account.projects (err, projects)->
    async.reduce projects, 0, calculateProjectUsage, callback
