module.exports = (callback)->
  response =
    _id: @organization._id
    name: @organization.name
  callback(null, response)

module.exports.organization = true
