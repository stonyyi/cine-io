Keen = require('keen.io')
client = Cine.server_lib('keen_client')
processKeenPeerEventsForProject = Cine.server_lib('reporting/peer/process_keen_peer_events_for_project')

exports.thisMonth = (projectId, callback)->
  now = new Date()
  exports.byMonth(projectId, now, callback)

exports.byMonth = (projectId, month, callback)->
  firstSecondInMonth = new Date(month.getFullYear(), month.getMonth(), 1)
  lastSecondInMonth = new Date(month.getFullYear(), month.getMonth() + 1)
  lastSecondInMonth.setSeconds(-1)

  queryOptions =
    event_collection: "peer-reporting"
    filters:
      [
        {
          property_name: 'projectId'
          operator: 'eq'
          property_value: projectId
        }
      ]
    timeframe:
      start: firstSecondInMonth.toISOString()
      end: lastSecondInMonth.toISOString()

  # console.log("running keen query", queryOptions)

  query = new Keen.Query("extraction", queryOptions)

  client.run query, (err, response)->
    if err
      console.log("GOT ERR", err)
      return callback(err)
    processKeenPeerEventsForProject(projectId, response.result, callback)
