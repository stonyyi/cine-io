fs = require('fs')

getFile = (params, callback)->
  return callback("id required", null, status: 404) unless params.id
  fs.readFile "#{Cine.root}/server/static_documents/#{params.id}", (err, content)->
    return callback("not found", null, status: 404) if err
    callback null, document: content.toString(), id: params.id

Show = (params, callback)->
  getFile params, (err, document)->
    callback(err, document)

module.exports = Show
