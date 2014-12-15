Project = Cine.server_model('project')
CalculateProjectBandwidth = Cine.server_lib('reporting/broadcast/calculate_project_bandwidth')
async = require('async')

exports.byMonth = (account, month, callback)->

  calculateProjectUsage = (accum, project, callback)->
    CalculateProjectBandwidth.byMonth project._id, month, (err, projectMonthlyBytes)->
      return callback(err) if err
      callback(null, accum + projectMonthlyBytes)

  account.projects (err, projects)->
    async.reduce projects, 0, calculateProjectUsage, callback

exports.total = (account, callback)->

  calculateProjectUsage = (accum, project, callback)->
    CalculateProjectBandwidth.total project._id, (err, projectMonthlyBytes)->
      return callback(err) if err
      callback(null, accum + projectMonthlyBytes)

  account.projects (err, projects)->
    async.reduce projects, 0, calculateProjectUsage, callback
