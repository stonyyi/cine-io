RendrView = require('rendr/shared/base/view')
React = require("react")

ReactView = RendrView.extend
  Component: ->
    throw new Error("You must override Component()")

  getInnerHtml: ->
    React.renderComponentToString @_renderComponent()

  postRender: ->
    React.renderComponent @_renderComponent(), @el

  _renderComponent: ->
    @Component @_renderOptions()

  _renderOptions: ->
    options = app: @app
    options.model = @model if @model
    options.collection = @collection if @collection
    options

module.exports = (id)->
  class extends ReactView
    @id: id
    className: id.replace('/', '-')
    Component: Cine.component(id)
