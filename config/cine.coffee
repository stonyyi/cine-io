Cine = {}

if typeof window == 'undefined'
  clientOrServerRequire = (path, app)->
    require "../apps/#{app}/#{path}"
else
  clientOrServerRequire = (path, app)->
    require path

# Client

# overridden by cine_server
Cine.require = (name)->
  require(name)

Cine.arch = (name) ->
  clientOrServerRequire("app/#{name}", 'shared')

Cine.component = (name, app='main') ->
  if typeof window == 'undefined'
    Cine.require("compiled/#{app}/components/#{name}")
  else
    require "app/components/#{name}"

Cine.model = (name) ->
  clientOrServerRequire("app/models/#{name}", 'shared')

Cine.collection = (name) ->
  clientOrServerRequire("app/collections/#{name}", 'shared')

Cine.lib = (name) ->
  clientOrServerRequire("app/lib/#{name}", 'shared')

Cine.controller = (name, app='main') ->
  clientOrServerRequire("app/controllers/#{name}_controller", app)

Cine.view = (controller_name, name, app='main') ->
  view_name = if name then "#{controller_name}/#{name}" else controller_name
  clientOrServerRequire("app/views/#{view_name}", app)

module.exports = Cine
