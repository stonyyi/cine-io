RendrView = Cine.view("base")
React = require("React")
module.exports = RendrView.extend
  getComponent: ->
    throw new Error("You must override getComponent()")

  getInnerHtml: ->
    React.renderComponentToString @getComponent()

  postRender: ->
    React.renderComponent @getComponent(), @el
