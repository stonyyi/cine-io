Base = Cine.model('base')
_ = require('underscore')

module.exports = class User extends Base
  @id: 'User'
  url: '/user'
  @plans: ['free', 'solo', 'startup', 'enterprise']

  isLoggedIn: ->
    @id?

  @include Cine.lib('date_value')

  createdAt: ->
    @_dateValue('createdAt')

  isNew: ->
    twoMinutesAgo = new Date
    twoMinutesAgo.setMinutes(twoMinutesAgo.getMinutes() - 2)
    @createdAt() > twoMinutesAgo

  isPermittedTo: (verb, object)->
    return false unless verb and object
    permissions = @get('permissions')
    return false unless _.isArray(permissions)
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
      console.debug('checking', name, id, permissions)
      canObject = _.any permissions, (permission)->
        permission.objectName == name && permission.objectId.toString() == id
      console.debug('object', canObject)
      return canObject
    else
      false
