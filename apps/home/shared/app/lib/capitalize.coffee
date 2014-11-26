_ = require('underscore')

module.exports = (str)->
  return unless _.isString(str)
  return '' if str.length == 0
  str.charAt(0).toUpperCase() + str.slice(1)
