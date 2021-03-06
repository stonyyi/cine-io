# https://github.com/HubSpot/humanize/blob/master/coffee/src/humanize.coffee

# Formats a number to a human-readable string.
# Localize by overriding the precision, thousand and decimal arguments.
module.exports = (number, precision=0, thousand=",", decimal=".") ->
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
