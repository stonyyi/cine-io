_ = require 'underscore'
# usage auth(app, success: ->, error: ->)
noop = ->

# usage auth(app, form, success: ->, completeSignup ->, error: ->)
# completeSignup is a function that is called when the user is new
exports.login = (app, form, options={})->
  _.defaults(options, success: noop, completeSignup: noop, error: noop)
  # button.button('loading')
  data = form.serialize()
  $.ajax
    type: "POST",
    url: "/login",
    data: data,
    success: (data, status, jqXHR)->
      # button.button('reset')
      ensureCompleteData(data, app, options)
    error: (jqXHR, textStatus, errorThrown)->
      console.debug('error')
      # button.button('reset')
      # animate.shake(form)
      options.error(jqXHR.responseText)

# usage auth(app, success: ->, error: ->)
exports.logout = (app, options={})->
  _.defaults(options, success: noop, error: noop)
  # button.button('loading')
  $.ajax
    type: 'GET'
    url: '/logout',
    success: (data, status, jqXHR)->
      # button.button('reset')
      app.currentUser.clear()
      options.success()
    error: (jqXHR, textStatus, errorThrown)->
      # button.button('reset')
      options.error()

# usage auth(app, button, success: ->, error: ->)
exports.updateAccount = (app, form, options={})->
  _.defaults(options, success: noop, error: noop)
  # button.button('loading')
  $.ajax
    type: "POST",
    url: "/api/1/-/update-account",
    data: form.serialize(),
    success: (data, status, jqXHR)->
      # button.button('reset')
      app.currentUser.set(data)
      options.success()
    error: (jqXHR, textStatus, errorThrown)->
      # button.button('reset')
      # animate.shake(form)
      response = JSON.parse(jqXHR.responseText)
      options.error(response.message)

ensureCompleteData = (data, app, options)->
  _.defaults(options, success: noop, complete: noop, relogin: true)
  if data.name && data.email
    app.currentUser.set(data)
    options.success()
  else
    options.completeSignup()
  options.complete()
