Keen = require('keen-js')
client = Cine.server_lib('keen_client')
_ = require('underscore')

# keenResultItem = {projectId: "someProjectId", result: 12345}
# accum = {"someProjectId": 12345, …}

moveKeenArrayToObject = (accum, keenResultItem)->
  accum[keenResultItem.projectId] = keenResultItem.result
  accum

module.exports = (month, callback)->
  firstSecondInMonth = new Date(month.getFullYear(), month.getMonth(), 1)
  lastSecondInMonth = new Date(month.getFullYear(), month.getMonth() + 1)
  lastSecondInMonth.setSeconds(-1)

  queryOptions =
    eventCollection: "peer-minutes"
    filters:
      [
        {
          property_name: 'action'
          operator: 'eq'
          property_value: "userTalkedInRoom"
        }
      ]
    groupBy: 'projectId'
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
    result = _.inject response.result, moveKeenArrayToObject, {}
    callback(null, result)
