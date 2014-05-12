Organization = Cine.model('organization')

module.exports = (callback)->
  org = new Organization
    name: @params.name
  org.save (err, org)=>
    return callback(err, null, status: 400) if err
    @user.permissions.push objectId: org._id, objectName: 'Organization'
    @user.save (err, user)->
      return callback(err, null, status: 400) if err
      callback(null, org.toJSON())

module.exports.user = true
