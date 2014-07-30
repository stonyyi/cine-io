_ = require('underscore')
locationData = Cine.config('edgecast_server_locations')

# roughly taken from http://www.sitepoint.com/forums/showthread.php?923652-Find-record-with-closest-latitude-longitude-from-stringify-ed-data-in-localstorage
vectorDistance = (dx, dy) ->
  Math.sqrt dx * dx + dy * dy

module.exports = (lat, lng)->
  targetLocation = lat: lat, lng: lng

  locationDistance = (location1, location2) ->
    dx = location1.lat - location2.lat
    dy = location1.lng - location2.lng
    vectorDistance dx, dy

  iterator = (prev, curr) ->
    prevDistance = locationDistance(targetLocation, prev)
    currDistance = locationDistance(targetLocation, curr)
    if prevDistance < currDistance then prev else curr

  firstResult = locationData[0]
  list = locationData.slice(1, locationData.length)

  _.reduce list, iterator, firstResult,
