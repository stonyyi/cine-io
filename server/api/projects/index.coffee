Project = Cine.server_model('project')
_ = require('underscore')
getUser = Cine.server_lib('get_user')
Show = Cine.api('projects/show')
async = require('async')

isProject = (permission)->
  permission.objectName == 'Project'

toJsonProxy = (model)->
  model.toJSON()

module.exports = (params, callback)->
  getUser params, (err, user, status)->
    return callback(err, user, status) if err
    projectIds = _.chain(user.permissions, isProject).pluck('objectId').value()
    return callback(null, []) if _.isEmpty(projectIds)
    scope = Project.find()
      .where(_id: {$in: projectIds})
      .sort(createdAt: 1)
    scope.exec (err, projects)->
      return callback(err, null, status: 400) if err
      async.map projects, Show.toJSON, (err, response)->
        callback(err, response)
