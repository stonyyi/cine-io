Show = Cine.api('streams/show')
getProject = Cine.server_lib('get_project')
addNextStreamToProject = Cine.server_lib('add_next_stream_to_project')

module.exports = (params, callback)->
  getProject params, requires: 'secret', (err, project, status)->
    return callback(err, project, status) if err
    addNextStreamToProject project, (err, stream)->
      return callback(err, null, status: 400) if err
      Show.legacyJSON(stream, callback)
