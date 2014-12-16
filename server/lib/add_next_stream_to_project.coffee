_ = require('underscore')
EdgecastStream = Cine.server_model('edgecast_stream')
Project = Cine.server_model('project')
createNewStreamInEdgecast = Cine.server_lib('create_new_stream_in_edgecast')
Account = Cine.server_model('account')
noop = ->

returnExistingStream = (project, callback)->
  # _.random is inclusive, so if there are 5 allocated streams
  # we want 0,1,2,3,4 not 0,1,2,3,4,5
  # offset by 5 returns null
  offset = _.random(project.streamsCount - 1)
  scope = EdgecastStream.findOne(_project: project._id).skip(offset)
  scope.exec callback

projectSummer = (accumulator, project)->
  project.streamsCount + accumulator

checkAllOtherProjects = (account, callback)->
  account.projects (err, projects)->
    return callback(err, null) if err
    streamsSum = _.inject(projects, projectSummer, 0) || 0
    callback null, streamsSum < account.streamLimit()

ensureAccountCanAddAnotherStream = (project, callback)->
  Account.findById project._account, (err, account)->
    return callback(err || 'no account for project') if err || !account
    # if the account has no plan, return an error
    return callback('account not on a plan') unless account.productPlans.broadcast.length > 0
    # if the account is on an infinite plan, just return true
    return callback(null, true) if account.streamLimit() == Infinity
    checkAllOtherProjects(account, callback)

allocateNewStreamToProject = (project, options, callback)->
  EdgecastStream.nextAvailable (err, stream)->
    return callback(err) if err
    return callback('Next stream not available, please try again later') if !stream
    stream._project = project._id
    stream.assignedAt = new Date
    stream.name = options.name if options.name
    stream.record = options.record if options.record

    stream.save (err, stream)->
      return callback(err, stream) if err
      createNewStreamInEdgecast(noop) if _.include ['test', 'production'], process.env.NODE_ENV
      Project.increment project, 'streamsCount', 1,  (err, updatedAttributes)->
        callback(err, stream)

module.exports = (project, options, callback)->
  if typeof options == "function"
    callback = options
    options = {}
  ensureAccountCanAddAnotherStream project, (err, canAddAnotherStream)->
    # console.log("checked", err, canAddAnotherStream)
    return returnExistingStream(project, callback) unless canAddAnotherStream
    allocateNewStreamToProject(project, options, callback)
