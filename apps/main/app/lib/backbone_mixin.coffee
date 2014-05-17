_ = require('underscore')
exports.componentDidMount = ->
  @_boundForceUpdate = @forceUpdate.bind(this, null)
  _.each @_getBackboneObjects(), (instance)=>
    instance.on "all", @_boundForceUpdate, this

exports.componentWillUnmount = ->
  _.each @_getBackboneObjects(), (instance)=>
    instance.off "all", @_boundForceUpdate

exports._getBackboneObjects = ->
  objects = @getBackboneObjects()
  if _.isArray(objects) then objects else [objects]
