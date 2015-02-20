mongoose = require('mongoose')
module.exports = (id)->
  (id instanceof mongoose.Types.ObjectId) || mongoose.Types.ObjectId.isValid(id)
