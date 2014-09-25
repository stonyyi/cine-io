fs = require('fs')
_ = require('underscore')
_str = require('underscore.string')
module.exports = (app) ->
  app.get '/health', (req, res)->
    # if req.param('dependencies')
    #   fs.readdir Cine.path("node_modules"), (err, files)->
    #     return res.status(400).send(err) if err
    #     nameToVersion = (accum, name)->
    #       return accum if _str.startsWith(name, '.')
    #       version = Cine.require("node_modules/#{name}/package.json").version
    #       accum[name] = version
    #       accum
    #     response = _.inject files, nameToVersion, {}
    #     res.status(200).send(response)
    # else
    res.status(200).send("OK")
