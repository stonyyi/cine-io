console.debug('required admin app')
rendr = require('rendr')
ModelUtils = require('rendr/shared/modelUtils')
_ = require('underscore')
express = require('express')
User = Cine.server_model('user')

module.exports = (originalApp)->
  modelUtils = new ModelUtils("#{Cine.root}/apps/shared/")
  serverOptions = Cine.middleware('rendr_server_options', originalApp)
  serverOptions.appData.rootPath = '/admin'
  options = _.extend(entryPath: "#{__dirname}/", modelUtils: modelUtils, serverOptions)
  server = rendr.createServer(options)
  server.expressApp.use Cine.middleware('ensure_site_admin')
  server
