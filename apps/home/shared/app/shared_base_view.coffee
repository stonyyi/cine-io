RendrView = require('rendr/shared/base/view')
React = require("react")

ReactView = RendrView.extend
  Component: ->
    throw new Error("You must override Component()")

  getInnerHtml: ->
    React.renderToString @_renderComponent()

  remove: ->
    RendrView.prototype.remove.call(this)
    React.unmountComponentAtNode @el

  postRender: ->
    @_renderReact()

  rerender: ->
    @_renderReact()

  _renderReact: ->
    React.render @_renderComponent(), @el

  _renderComponent: ->
    @renderedComponent = React.createFactory(@Component)(@_renderOptions())

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
