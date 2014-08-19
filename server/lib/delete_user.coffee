# TODO DEPRECATED: does way different things
async = require('async')
Project = Cine.server_model('project')
EdgecastStream = Cine.server_model('edgecast_stream')

multiDelete = (Model, query, callback)->
  query = query
  update =
    $set: {deletedAt: new Date}
  options = multi: true
  Model.update query, update, options, callback


module.exports = (user, callback)->
  asyncCalls =
    deleteUser: (callback)->
      user.deletedAt = new Date
      # save returns more than err, user
      # but we only want to return user
      user.save (err, user)->
        callback(err, user)

    deleteProjects: (callback)->
      query = _id: {$in: user.permissionIdsFor('Project')}
      multiDelete Project, query, callback

    deleteStreams: (callback)->
      query = _project: {$in: user.permissionIdsFor('Project')}
      multiDelete EdgecastStream, query, callback

  async.parallel asyncCalls, (err, results)->
    callback(err, results.deleteUser)
