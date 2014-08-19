async = require('async')
Project = Cine.server_model('project')
EdgecastStream = Cine.server_model('edgecast_stream')
_ = require('underscore')
multiDelete = (Model, query, callback)->
  query = query
  update =
    $set: {deletedAt: new Date}
  options = multi: true
  Model.update query, update, options, callback

module.exports = (account, callback)->
  asyncCalls =
    deleteAccount: (callback)->
      account.deletedAt = new Date
      # save returns more than err, account
      # but we only want to return account
      account.save (err, account)->
        callback(err, account)

    deleteProjects: (callback)->
      query = _account: {$in: [account._id]}
      multiDelete Project, query, callback

    deleteStreams: (callback)->
      projectQuery = _account: {$in: [account._id]}
      Project.find projectQuery, (err, projects)->
        query = _project: {$in: _.pluck(projects, '_id')}
        multiDelete EdgecastStream, query, callback

  async.parallel asyncCalls, (err, results)->
    callback(err, results.deleteAccount)
