Project = Cine.server_model('project')
CalculateProjectPeerMinutes = Cine.server_lib('reporting/peer/calculate_project_peer_minutes')
async = require('async')

exports.byMonth = (account, month, callback)->

  calculateProjectUsage = (accum, project, callback)->
    CalculateProjectPeerMinutes.byMonth project._id, month, (err, projectMonthlyBytes)->
      return callback(err) if err
      callback(null, accum + projectMonthlyBytes)

  account.projects (err, projects)->
    async.reduce projects, 0, calculateProjectUsage, callback
