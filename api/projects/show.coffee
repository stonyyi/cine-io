module.exports = (callback)->
  response =
    id: @project._id.toString()
    name: @project.name
  callback(null, response)

module.exports.project = true
