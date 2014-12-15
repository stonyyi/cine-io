Project = Cine.server_model('project')
CalculateProjectStorage = Cine.server_lib('reporting/storage/calculate_project_storage')
async = require('async')

exports.byMonth = (account, month, callback)->

  calculateProjectUsage = (accum, project, callback)->
    CalculateProjectStorage.byMonth project, month, (err, projectMonthlyBytes)->
      return callback(err) if err
      callback(null, accum + projectMonthlyBytes)

  account.projects (err, projects)->
    async.reduce projects, 0, calculateProjectUsage, callback

exports.total = (account, callback)->

  calculateProjectUsage = (accum, project, callback)->
    CalculateProjectStorage.total project, (err, projectTotalBytes)->
      return callback(err) if err
      callback(null, accum + projectTotalBytes)

  account.projects (err, projects)->
    async.reduce projects, 0, calculateProjectUsage, callback
