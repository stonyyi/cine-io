# Returns the plural version of a given word if the value is not 1. The default suffix is 's'.

module.exports = (number, singular, plural) ->
  return unless number? and singular?

  plural ?= singular + "s"

  if parseInt(number, 10) is 1 then singular else plural
