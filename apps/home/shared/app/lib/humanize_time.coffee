# 1000 second: 1 second
# 65000 seconds: 1 minute, 5 seconds
day = 60 * 60 * 24
hour = 60 * 60
minute = 60

module.exports = (milliseconds)->
  obj = module.exports.toObject(milliseconds)
  result = [pluralize(obj.days, "day"), pluralize(obj.hours, "hour"), pluralize(obj.minutes, "minute"), pluralize(obj.seconds, "second")]
  result = []
  for key in ["day", "hour", "minute", "second"]
    count = obj["#{key}s"]
    result.push(pluralize(count, key)) if count
  switch result.length
    when 0
      return '0 seconds'
    when 1
      return result[0]
    when 2
      return "#{result[0]} and #{result[1]}"
    else
      # http://stackoverflow.com/questions/14763997/javascript-array-to-sentence
      result.slice(0, result.length - 1).join(', ') + ", and " + result.slice(-1);

module.exports.toObject = (milliseconds) ->
  seconds = Math.ceil(milliseconds / 1000)
  result = {}

  if seconds > day
    result.days = Math.floor(seconds / day)
    seconds -= (result.days * day)

  if seconds > hour
    result.hours = Math.floor(seconds / hour)
    seconds -= (result.hours * hour)

  if seconds > minute
    result.minutes = Math.floor(seconds / minute)
    seconds -= (result.minutes * minute)

  if seconds != 0
    result.seconds = seconds

  return result

pluralize = (count, singular)->
  return null if count == 0
  "#{count} #{if count == 1 then singular else "#{singular}s"}"
