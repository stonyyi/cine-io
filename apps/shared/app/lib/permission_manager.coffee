_ = require 'underscore'

module.exports = class PermissionManager
  constructor: (@permissions)->

  clearPermissions: ->
    @permissions = null

  setPermissions: (@permissions)->

  addPermission: (objectName, objectId)->
    @permissions.push(objectName: objectName, objectId: objectId) unless _.findWhere(@permissions, objectName: objectName, objectId: objectId)

  idsForPermission: (objectName)->
    return [] unless _.isArray(@permissions)
    _.chain(@permissions).where(objectName: objectName).pluck('objectId').value()

  check: (verb, object)->
    return false unless verb and object
    return false unless _.isArray(@permissions)
    return false if _.isString(object)

    # now check each object to see if it is in the permissions list
    if object
      # Simple object
      if object.objectName && object.objectId
        name = object.objectName
        id = object.objectId.toString()
      # Mongoose document
      else if object.constructor && object.constructor.modelName
        name = object.constructor.modelName
        id = object._id.toString()
      # Backbone model
      else if object.constructor && object.constructor.id
        name = object.constructor.id
        id = object.id.toString()
      else
        return false
      # if object instanceof Backbone.Model
      #   name = object.constructor.name
      #   console.debug('object', object)
      #   console.debug('name', name)
      #   id = object.id.toString()
      # else
      #   name = object.constructor.modelName
      #   id = object._id.toString()
      console.debug('checking', name, id, @permissions)
      canObject = _.any @permissions, (permission)->
        permission.objectName == name && permission.objectId.toString() == id
      console.debug('object', canObject)
      return canObject
    else
      false
