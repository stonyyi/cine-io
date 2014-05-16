RendrView = Cine.view("base")
React = require("react")

ReactView = RendrView.extend
  getComponent: ->
    throw new Error("You must override getComponent()")

  getInnerHtml: ->
    React.renderComponentToString @getComponent()

  postRender: ->
    React.renderComponent @getComponent(), @el


module.exports = (id)->
  Component = Cine.component(id)
  class extends ReactView
    @id: id
    className: id.replace('/', '-')
    getComponent: ->
      Component()
