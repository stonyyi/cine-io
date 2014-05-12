EdgecastStream = Cine.model('edgecast_stream')
createNewStreamInEdgecast = Cine.lib('create_new_stream_in_edgecast')
noop = ->

module.exports = (organization, params, callback)->
  EdgecastStream.nextAvailable (err, stream)->
    return callback(err, null, status: 400) if err
    return callback('Next stream not available, please try again later', null, status: 400) if !stream
    stream._organization = organization._id
    stream.save (err, stream)->
      return callback(err, null, status: 400) if err
      createNewStreamInEdgecast(noop)
      callback(null, stream.toJSON())