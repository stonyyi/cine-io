debug = require('debug')('cine:fetch_all_projects_peer_milliseconds')
Keen = require('keen-js')
client = Cine.server_lib('keen_client')
_ = require('underscore')

# keenResultItem = {projectId: "someProjectId", result: 12345}
# accum = {"someProjectId": 12345, …}

moveKeenArrayToObject = (accum, keenResultItem)->
  accum[keenResultItem.projectId] = keenResultItem.result
  accum

exports.byMonth = (month, callback)->
  firstSecondInMonth = new Date(month.getFullYear(), month.getMonth(), 1)
  lastSecondInMonth = new Date(month.getFullYear(), month.getMonth() + 1)
  lastSecondInMonth.setSeconds(-1)
  exports.between(firstSecondInMonth, lastSecondInMonth, callback)

exports.between = (start, end, callback)->
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
      start: start.toISOString()
      end:   end.toISOString()

  debug("running keen query", queryOptions)

  query = new Keen.Query("sum", queryOptions)

  client.run query, (err, response)->
    debug("ran keen query", err, response)
    if err
      console.dir(err)
      return callback(err)
    result = _.inject response.result, moveKeenArrayToObject, {}
    callback(null, result)
