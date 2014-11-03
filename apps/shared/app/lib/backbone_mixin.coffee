_ = require('underscore')
exports.componentDidMount = ->
  # sometimes the component will try to re-render but it has been unmounted
  # I don't know why. Then we try to render it again. It's a bit confusing
  @_boundBackboneObjects = []
  @_boundForceUpdate = =>
    @forceUpdate() if @isMounted()
  _.each @_getBackboneObjects(), @listenToBackboneChangeEvents

exports.componentWillUnmount = ->
  _.each @_boundBackboneObjects, (instance)=>
    instance.off "all", @_boundForceUpdate

exports.listenToBackboneChangeEvents = (modelOrCollection)->
  return if _.contains(@_boundBackboneObjects, modelOrCollection)
  @_boundBackboneObjects.push(modelOrCollection)
  modelOrCollection.on "all", @_boundForceUpdate, this

exports._getBackboneObjects = ->
  console.error('getBackboneObjects is not defined') unless @getBackboneObjects
  objects = @getBackboneObjects()
  objects = if _.isArray(objects) then objects else [objects]
  # remove any null/undefineds
  _.compact(objects)
