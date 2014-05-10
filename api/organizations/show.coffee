module.exports = (organization, params, callback)->
  response =
    _id: organization._id
    name: organization.name
  callback(null, response)
