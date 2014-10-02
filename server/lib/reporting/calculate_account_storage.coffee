Project = Cine.server_model('project')
CalculateProjectStorageOnEdgecast = Cine.server_lib('reporting/calculate_project_storage_on_edgecast')
async = require('async')

exports.onEdgecast = (account, callback)->

  calculateProjectUsage = (accum, project, callback)->
    CalculateProjectStorageOnEdgecast.total project, (err, projectMonthlyBytes)->
      return callback(err) if err
      callback(null, accum + projectMonthlyBytes)

  account.projects (err, projects)->
    async.reduce projects, 0, calculateProjectUsage, callback
