console.debug('required main app')
rendr = require('rendr')
ModelUtils = require('rendr/shared/modelUtils')
_ = require('underscore')

module.exports = (app)->
  modelUtils = new ModelUtils("#{Cine.root}/apps/shared/")
  serverOptions = Cine.middleware('rendr_server_options', app)
  options = _.extend(entryPath: "#{__dirname}/", modelUtils: modelUtils, serverOptions)
  rendr.createServer(options)
