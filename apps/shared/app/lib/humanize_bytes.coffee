# https://github.com/HubSpot/humanize/blob/master/coffee/src/humanize.coffee
TB = 1099511627776
GB = 1073741824
MB = 1048576
KB = 1024

module.exports = (filesize, thousand=',') ->
  if filesize >= TB
    sizeStr = formatNumber(filesize / TB, 2, thousand) + " TB"
  else if filesize >= GB
    sizeStr = formatNumber(filesize / GB, 2, thousand) + " GB"
  else if filesize >= MB
    sizeStr = formatNumber(filesize / MB, 2, thousand) + " MB"
  else if filesize >= KB
    sizeStr = formatNumber(filesize / KB, 0, thousand) + " KB"
  else
    sizeStr = formatNumber(filesize, 0) + pluralize filesize, " byte"

  sizeStr

module.exports.formatString = (filesize)->
  if filesize >= TB
    return "TB"
  else if filesize >= GB
    return "GB"
  else if filesize >= MB
    return "MB"
  else if filesize >= KB
    return "KB"
  else
    return "byte"

module.exports.TB = TB
module.exports.GB = GB
module.exports.MB = MB
module.exports.KB = KB

# Formats a number to a human-readable string.
# Localize by overriding the precision, thousand and decimal arguments.
formatNumber = (number, precision=0, thousand=",", decimal=".") ->
  # Create some private utility functions to make the computational
  # code that follows much easier to read.

  firstComma = (number, thousand, position) ->
    if position then number.substr(0, position) + thousand else ""

  commas = (number, thousand, position) ->
    number.substr(position).replace /(\d{3})(?=\d)/g, "$1" + thousand

  decimals = (number, decimal, usePrecision) ->
    if usePrecision then decimal + toFixed(Math.abs(number), usePrecision).split(".")[1] else ""

  usePrecision = normalizePrecision precision

  # Do some calc
  negative = number < 0 and "-" or ""
  base = parseInt(toFixed(Math.abs(number or 0), usePrecision), 10) + ""
  mod = if base.length > 3 then base.length % 3 else 0

  # Format the number
  negative +
  firstComma(base, thousand, mod) +
  commas(base, thousand, mod) +
  decimals(number, decimal, usePrecision)

# Fixes binary rounding issues (eg. (0.615).toFixed(2) === "0.61")
toFixed = (value, precision) ->
  precision ?= normalizePrecision precision, 0
  power = Math.pow 10, precision

  # Multiply up by precision, round accurately, then divide and use native toFixed()
  (Math.round(value * power) / power).toFixed precision

# Ensures precision value is a positive integer
normalizePrecision = (value, base) ->
  value = Math.round Math.abs value
  if isNaN(value) then base else value

# Returns the plural version of a given word if the value is not 1. The default suffix is 's'.
pluralize = (number, singular, plural) ->
  return unless number? and singular?

  plural ?= singular + "s"

  if parseInt(number, 10) is 1 then singular else plural
