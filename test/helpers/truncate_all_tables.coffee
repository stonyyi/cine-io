_ = require 'underscore'
async = require 'async'
mongoose = require 'mongoose'

module.exports = (callback)->
  mongooseIteration = _.map mongoose.models, (Model)->
    (callback)->
      Model.remove callback

  async.parallel mongooseIteration, callback
