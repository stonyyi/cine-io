EdgecastStream = Cine.model('edgecast_stream')

fmleProfile = (stream, callback)->
  throw new Error('not implemented')


toJSON = (stream, callback)->
  callback(null, stream.toJSON())

Show = (callback)->
  return callback("id required", null, status: 400) unless @params.id
  EdgecastStream.findOne _id: @params.id, _project: @project.id, (err, stream)=>
    return callback(err, null, status: 400) if err
    return callback("stream not found", null, status: 404) unless stream
    return fmleProfile(stream, callback) if @params.fmleProfile == 'true'
    toJSON(stream, callback)

module.exports = Show
module.exports.toJSON = toJSON
module.exports.project = true
