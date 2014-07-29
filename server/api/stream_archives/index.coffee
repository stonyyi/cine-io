_ = require('underscore')
EdgecastStream = Cine.server_model('edgecast_stream')
getProject = Cine.server_lib('get_project')
listArchivedStreamFiles = Cine.server_lib('list_archived_stream_files')

onlySelectUsefulValues = (ftpFile)->
  name: ftpFile.name
  url: "http://vod.cine.io/cines/#{ftpFile.name}"
  size: ftpFile.size
  date: ftpFile.date

dateSort = (ftpFile)->
  ftpFile.date

ftpFilesToResponse = (ftpFiles)->
  _.chain(ftpFiles).map(onlySelectUsefulValues).sortBy(dateSort).value()

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
      return callback("stream not found", null, status: 404) unless stream
      listArchivedStreamFiles stream, (err, files)->
        return callback(err, null, status: 400) if err
        callback(null, ftpFilesToResponse(files))
