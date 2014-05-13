module.exports = (callback)->
  response =
    _id: @project._id
    name: @project.name
  callback(null, response)

module.exports.project = true
