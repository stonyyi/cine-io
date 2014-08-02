Project = Cine.server_model('project')
CalculateProjectUsage = Cine.server_lib('reporting/calculate_project_usage')
async = require('async')

exports.byMonth = (user, month, callback)->
  projectIds = user.permissionIdsFor('Project')

  calculateProjectUsage = (accum, projectId, callback)->
    CalculateProjectUsage.byMonth projectId, month, (err, projectMonthlyBytes)->
      return callback(err) if err
      callback(null, accum + projectMonthlyBytes)

  async.reduce projectIds, 0, calculateProjectUsage, callback

exports.total = (user, callback)->
  projectIds = user.permissionIdsFor('Project')

  calculateProjectUsage = (accum, projectId, callback)->
    CalculateProjectUsage.total projectId, (err, projectMonthlyBytes)->
      return callback(err) if err
      callback(null, accum + projectMonthlyBytes)

  async.reduce projectIds, 0, calculateProjectUsage, callback
