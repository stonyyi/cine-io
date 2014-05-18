RendrView = Cine.view("base")
React = require("react")

ReactView = RendrView.extend
  Component: ->
    throw new Error("You must override Component()")

  getInnerHtml: ->
    React.renderComponentToString @Component(app: @app)

  postRender: ->
    React.renderComponent @Component(app: @app), @el


module.exports = (id)->
  class extends ReactView
    @id: id
    className: id.replace('/', '-')
    Component: Cine.component(id)
