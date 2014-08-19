Project = Cine.server_model('project')
_ = require('underscore')
getAccount = Cine.server_lib('get_account')
Show = Cine.api('projects/show')
async = require('async')

isProject = (permission)->
  permission.objectName == 'Project'

toJsonProxy = (model)->
  model.toJSON()

module.exports = (params, callback)->
  getAccount params, (err, account, status)->
    return callback(err, account, status) if err
    account.projects (err, projects)->
      return callback(err, null, status: 400) if err
      async.map projects, Show.toJSON, (err, response)->
        callback(err, response)
