utils = require("rendr/server/utils")
_ = require("underscore")
clc = require "cli-color"

createApiErr = (message, response, status, path, params)->
  console.log('sending an err from the data_adapter', err, status)
  err = new Error(message)
  err.status = status || message.status
  err.extra = {path: path, params: params}
  _.extend(err, response) if response
  err

class FormatResponseForRendr
  constructor: (@jsonpCallback, @callbackFromRendr, @path, @params)->
  callback: (err, response, options = {})=>
    err = createApiErr(err, response, options.status, @path, @params) if err
    options.status ||= 200
    options = {statusCode: options.status}
    options.jsonp = true if @jsonpCallback?
    @callbackFromRendr(err, options, response)

# This class makes a "request" to an action in server/api
# the callback must respond with (err, status, response).
class InternalApiRequest
  constructor: (@app, @method, @path, @params)->
    @method = 'get' if @method.toLowerCase() == 'head'
  request: (callback)->
    controller = @_controller()
    controller(@params, callback)
  _controller: ->
    route = @_matchingRoute()
    # add the interpolated params
    throw new Error "no route for #{@path}!" unless route
    _.extend(@params, route.params)
    route.route.stack[0].handle
  _matchingRoute: ->
    method = @method.toLowerCase()
    # verb_matching_routes = @app.routes[@method.toLowerCase()]
    _.find @app._router.stack, (route)=>
      return unless route.route
      return unless route.route.methods[method]
      route.match("/api#{@path}")

class DataAdapter
  constructor: (@app) ->

  #
  # `req`: Actual request object from Express/Connect.
  # `api`: Object describing API call; properties including 'path', 'query', etc.
  # `options`: (optional) Options.
  # `callback`: Rendr Callback.
  #
  request: (req, api, options, callback) ->
    path = api.path
    method = req.method

    if arguments.length is 3
      callback = options
      options = {}

    params = _.extend({}, api.body, api.query)
    params.sessionUserId = req.user
    params.remoteIpAddress = req.headers['x-forwarded-for'] || req.connection.remoteAddress

    console.log(clc.blueBright("[API]"), "#{method} #{path}", params)

    apiReq = new InternalApiRequest(@app, method, path, params)
    rendrResponse = new FormatResponseForRendr(params.callback, callback, path, params)
    apiReq.request(rendrResponse.callback)

  # Convert 4xx, 5xx responses to be errors.
  # TODO-TJS use this
  getErrForResponse: (res, options) ->
    console.log('in getErrForResponse')
    status = undefined
    err = undefined
    status = +res.statusCode
    err = null
    if utils.isErrorStatus(status, options)
      err = new Error(status + " status")
      err.status = status
      err.body = res.body
    err

module.exports = DataAdapter
module.exports.InternalApiRequest = InternalApiRequest
