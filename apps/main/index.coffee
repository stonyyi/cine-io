console.debug('required main app')
rendr = require('rendr')
_ = require('underscore')

module.exports = (app)->
  serverOptions = Cine.middleware('rendr_server_options', app)
  options = _.extend(entryPath: "#{__dirname}/", serverOptions)
  rendr.createServer(options)
