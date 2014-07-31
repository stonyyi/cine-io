Show = Cine.api('streams/show')
getProject = Cine.server_lib('get_project')
addNextStreamToProject = Cine.server_lib('add_next_stream_to_project')
convertIpAddressToEdgecastServer = Cine.server_lib('convert_ip_address_to_edgecast_server')

module.exports = (params, callback)->
  getProject params, requires: 'secret', (err, project, status)->
    return callback(err, project, status) if err
    record = params.record == 'true'
    addNextStreamToProject project, name: params.name, record: record, (err, stream)->
      return callback(err, null, status: 400) if err
      streamOptions = {}
      Show.addEdgecastServerToStreamOptions(streamOptions, params)
      Show.fullJSON(stream, streamOptions, callback)
