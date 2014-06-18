EdgecastStream = Cine.server_model('edgecast_stream')
getProject = Cine.server_lib('get_project')
StreamShow = Cine.api('projects/show')

module.exports = (params, callback)->
  getProject params, requires: 'secret', userOverride: true, (err, project, options)->
    return callback(err, project, options) if err
    return callback("id required", null, status: 400) unless params.id
    query =
      _id: params.id
      _project: project._id
      deletedAt:
        $exists: false

    EdgecastStream.findOne query, (err, stream)->
      return callback(err, null, status: 400) if err
      stream.name = params.name
      stream.save (err, stream)->
        return callback(err, null, status: 400) if err
        StreamShow.toJSON(stream, callback)