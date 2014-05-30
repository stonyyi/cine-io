EdgecastStream = Cine.server_model('edgecast_stream')
Project = Cine.server_model('project')
createNewStreamInEdgecast = Cine.server_lib('create_new_stream_in_edgecast')
_ = require('underscore')
noop = ->

projectLimit = (project)->
  switch project.plan
    when 'free', 'test' then 1
    when 'solo' then 5
    when 'startup', 'enterprise' then Infinity
    else throw new Error("Don't know this plan")

isAtProjectLimit = (project)->
  project.streamsCount >= projectLimit(project)

projectLimitMessage = (project)->
  "#{project.plan} plans can only have #{projectLimit(project)} available streams"

returnExistingStream = (project, callback)->
  # _.random is inclusive, so if there are 5 allocated streams
  # we want 0,1,2,3,4 not 0,1,2,3,4,5
  # offset by 5 returns null
  offset = _.random(project.streamsCount - 1)
  scope = EdgecastStream.findOne(_project: project._id).skip(offset)
  scope.exec callback

allocateNewStreamToProject = (project, callback)->
  EdgecastStream.nextAvailable (err, stream)->
    return callback(err) if err
    return callback('Next stream not available, please try again later', null, status: 400) if !stream
    stream._project = project._id
    stream.assignedAt = new Date

    stream.save (err, stream)->
      return callback(err, stream) if err
      createNewStreamInEdgecast(noop) if _.include ['test', 'production'], process.env.NODE_ENV
      Project.increment project, 'streamsCount', 1,  (err, updatedAttributes)->
        callback(err, stream)

module.exports = (project, callback)->
  return returnExistingStream(project, callback) if isAtProjectLimit(project)
  allocateNewStreamToProject(project, callback)
