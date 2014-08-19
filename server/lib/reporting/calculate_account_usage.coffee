Project = Cine.server_model('project')
CalculateProjectUsage = Cine.server_lib('reporting/calculate_project_usage')
async = require('async')

exports.byMonth = (account, month, callback)->

  calculateProjectUsage = (accum, project, callback)->
    CalculateProjectUsage.byMonth project._id, month, (err, projectMonthlyBytes)->
      return callback(err) if err
      callback(null, accum + projectMonthlyBytes)

  account.projects (err, projects)->
    async.reduce projects, 0, calculateProjectUsage, callback

exports.total = (account, callback)->

  calculateProjectUsage = (accum, project, callback)->
    CalculateProjectUsage.total project._id, (err, projectMonthlyBytes)->
      return callback(err) if err
      callback(null, accum + projectMonthlyBytes)

  account.projects (err, projects)->
    async.reduce projects, 0, calculateProjectUsage, callback
