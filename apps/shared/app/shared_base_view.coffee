RendrView = require('rendr/shared/base/view')
React = require("react")

ReactView = RendrView.extend
  Component: ->
    throw new Error("You must override Component()")

  getInnerHtml: ->
    React.renderComponentToString @_renderComponent()

  postRender: ->
    @_renderReact()

  rerender: ->
    @_renderReact()

  _renderReact: ->
    React.renderComponent @_renderComponent(), @el

  _renderComponent: ->
    @renderedComponent = @Component @_renderOptions()

  _renderOptions: ->
    options = app: @app, options: @options
    options.model = @model if @model
    options.collection = @collection if @collection
    options

module.exports = (id, app='main')->
  class extends ReactView
    @id: id
    className: id.replace('/', '-')
    Component: Cine.component(id, app)
