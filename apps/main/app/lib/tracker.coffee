_ = require('underscore')
tracker = exports

tracker.preventTracking = typeof window is 'undefined'
namespace = if typeof window is 'undefined' then global else window

trackGoogleAnalytics = (eventName)->
  tracker.ga = namespace.ga if tracker.ga != namespace.ga
  console.log('tracking', eventName, data)
  if tracker.ga
    gaOptions =
      hitType: 'event'       # Required.
      eventCategory: 'KPI'   # Required.
      eventAction: eventName # Required.
    ga 'send', gaOptions

trackEvent = (eventName, data={})->
  throw new Error("cannot track events on server") if tracker.preventTracking
  trackGoogleAnalytics(eventName)

tracker.userSignup = ->
  trackEvent('userSignup')

tracker.load = ->
  tracker.ga = ga if typeof ga isnt 'undefined'

# for testing
tracker.unload = ->
  delete tracker.ga
