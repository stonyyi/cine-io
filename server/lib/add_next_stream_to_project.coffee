_ = require('underscore')
EdgecastStream = Cine.server_model('edgecast_stream')
Project = Cine.server_model('project')
createNewStreamInEdgecast = Cine.server_lib('create_new_stream_in_edgecast')
User = Cine.server_model('user')
noop = ->

infinitePlan = (plan)->
  plan in ['startup', 'enterprise', 'test']

returnExistingStream = (project, callback)->
  # _.random is inclusive, so if there are 5 allocated streams
  # we want 0,1,2,3,4 not 0,1,2,3,4,5
  # offset by 5 returns null
  offset = _.random(project.streamsCount - 1)
  scope = EdgecastStream.findOne(_project: project._id).skip(offset)
  scope.exec callback

projectSummer = (accumulator, project)->
  project.streamsCount + accumulator

checkAllOtherProjects = (user, callback)->
  user.projects (err, projects)->
    return callback(err, null) if err
    streamsSum = _.inject(projects, projectSummer, 0) || 0
    callback null, streamsSum < user.streamLimit()

ensureUserCanAddAnotherStream = (project, callback)->
  query = "permissions.objectId": project._id, "permissions.objectName": 'Project'
  User.findOne query, (err, user)->
    return callback(err || 'no user for project') if err || !user
    # if the user has no plan, return an error
    return callback('user not on a plan') unless user.plan
    # if the user is on an infinite plan, just return true
    return callback(null, true) if user.streamLimit() == Infinity
    checkAllOtherProjects(user, callback)

allocateNewStreamToProject = (project, options, callback)->
  EdgecastStream.nextAvailable (err, stream)->
    return callback(err) if err
    return callback('Next stream not available, please try again later') if !stream
    stream._project = project._id
    stream.assignedAt = new Date
    stream.name = options.name if options.name

    stream.save (err, stream)->
      return callback(err, stream) if err
      createNewStreamInEdgecast(noop) if _.include ['test', 'production'], process.env.NODE_ENV
      Project.increment project, 'streamsCount', 1,  (err, updatedAttributes)->
        callback(err, stream)

module.exports = (project, options, callback)->
  if typeof options == "function"
    callback = options
    options = {}
  ensureUserCanAddAnotherStream project, (err, canAddAnotherStream)->
    return returnExistingStream(project, callback) unless canAddAnotherStream
    allocateNewStreamToProject(project, options, callback)
