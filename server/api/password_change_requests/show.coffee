PasswordChangeRequest = Cine.server_model 'password_change_request'

toJSON = (pcr, callback)->
  pcrJSON =
    id: pcr._id.toString()
    identifier: pcr.identifier
  callback(null, pcrJSON)

Show = (params, callback) ->
  return callback("missing identifier", null, status: 400) unless params.identifier
  PasswordChangeRequest.findOne identifier: params.identifier, (err, pcr)->
    return callback(err || 'not found', null, status: 400) if err || !pcr
    toJSON(pcr, callback)

module.exports = Show
