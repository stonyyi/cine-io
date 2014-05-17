RendrView = Cine.view("base")
React = require("react")
isServer = typeof window isnt 'undefined'
defaultOptions = {}
defaultOptions = {jQuery: jQuery} if isServer
_ = require('underscore')

ReactView = RendrView.extend
  Component: ->
    throw new Error("You must override Component()")

  getInnerHtml: ->
    props = _.extend(app: @app, defaultOptions)
    React.renderComponentToString @Component(props)

  postRender: ->
    props = _.extend(app: @app, defaultOptions)
    React.renderComponent @Component(props), @el


module.exports = (id)->
  class extends ReactView
    @id: id
    className: id.replace('/', '-')
    Component: Cine.component(id)
