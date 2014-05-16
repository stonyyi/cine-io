EdgecastStream = Cine.server_model('edgecast_stream')
createNewStreamInEdgecast = Cine.server_lib('create_new_stream_in_edgecast')
_ = require('underscore')
Show = Cine.api('streams/show')
noop = ->

module.exports = (callback)->
  EdgecastStream.nextAvailable (err, stream)=>
    return callback(err, null, status: 400) if err
    return callback('Next stream not available, please try again later', null, status: 400) if !stream
    stream._project = @project._id
    stream.save (err, stream)->
      return callback(err, null, status: 400) if err
      createNewStreamInEdgecast(noop) if _.include ['test', 'production'], process.env.NODE_ENV
      Show.toJSON(stream, callback)

module.exports.project = true
