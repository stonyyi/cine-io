Base = require('rendr/shared/base/collection')
noop = ->

module.exports = class CollectionBase extends Base

  initialize: (models, options)->
    Base.prototype.initialize.call(this, models, options)
    @afterInitialize()

  afterInitialize: noop

  api: ->
    @app.apiVersion
