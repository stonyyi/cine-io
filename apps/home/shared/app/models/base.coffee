Base = require 'rendr/shared/base/model'
_ = require('underscore')
isServer = typeof window == 'undefined'
noop = ->

module.exports = class ModelBase extends Base

  initialize: (models, options)->
    Base.prototype.initialize.call(this, models, options)
    @afterInitialize()

  afterInitialize: noop

  api: ->
    @app.apiVersion

  # http://arcturo.github.io/library/coffeescript/03_classes.html
  # adapted to use underscore
  @include: (obj) ->
    _.extend(this::, obj)
    obj.included?.apply(this)
    this

  # the default implementation will always store models
  # but we don't want to store models without ids
  store: ->
    return unless @id
    Base::store.call(this)
