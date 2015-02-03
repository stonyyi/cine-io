Keen = require('keen-js')
client = Cine.server_lib('keen_client')

exports.thisMonth = (projectId, callback)->
  now = new Date()
  exports.byMonth(projectId, now, callback)

exports.byMonth = (projectId, month, callback)->
  firstSecondInMonth = new Date(month.getFullYear(), month.getMonth(), 1)
  lastSecondInMonth = new Date(month.getFullYear(), month.getMonth() + 1)
  lastSecondInMonth.setSeconds(-1)

  queryOptions =
    eventCollection: "peer-minutes"
    filters:
      [
        {
          property_name: 'projectId'
          operator: 'eq'
          property_value: projectId
        }
        {
          property_name: 'action'
          operator: 'eq'
          property_value: "userTalkedInRoom"
        }
      ]
    targetProperty: "talkTimeInMilliseconds"
    timeframe:
      start: firstSecondInMonth.toISOString()
      end: lastSecondInMonth.toISOString()

  # console.log("running keen query", queryOptions)

  query = new Keen.Query("sum", queryOptions)

  client.run query, (err, response)->
    if err
      console.dir(err)
      return callback(err)
    return callback(null, 0) unless response?.result
    callback(null, response.result)
