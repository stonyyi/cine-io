_ = require('underscore')
tracker = exports

tracker.preventTracking = typeof window is 'undefined'

trackEvent = (eventName, data={})->
  throw new Error("cannot track events on server") if tracker.preventTracking
  console.log('tracking', eventName, data)
  if tracker.ga
    gaOptions =
      hitType: 'event'       # Required.
      eventCategory: 'KPI'   # Required.
      eventAction: eventName # Required.
    ga 'send', gaOptions

tracker.userSignup = ->
  trackEvent('userSignup')

tracker.load = ->
  tracker.ga = ga if typeof ga isnt 'undefined'

# for testing
tracker.unload = ->
  delete tracker.ga
