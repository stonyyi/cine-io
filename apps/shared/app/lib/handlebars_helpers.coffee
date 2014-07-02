module.exports = (Handlebars) ->
  ## control flow
  ifEqual: (value1, value2, options)->
    return options.fn this if value1 == value2
    options.inverse this if options.inverse
