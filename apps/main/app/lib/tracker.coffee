_ = require('underscore')
tracker = exports

tracker.preventTracking = typeof window is 'undefined'
namespace = if typeof window is 'undefined' then global else window

trackGoogleAnalytics = (eventName, data)->
  # ga will change from an array to the actual ga
  # underneath us, and there's no way of knowing when that happens
  tracker.ga = namespace.ga if tracker.ga != namespace.ga
  if tracker.ga
    gaOptions =
      hitType: 'event'       # Required.
      eventCategory: 'KPI'   # Required.
      eventAction: eventName # Required.
    gaOptions.eventValue = data.value if data.value
    ga 'send', gaOptions

trackEvent = (eventName, data={})->
  throw new Error("cannot track events on server") if tracker.preventTracking
  console.log('tracking', eventName, data)
  trackGoogleAnalytics(eventName, data)

tracker.userSignup = ->
  trackEvent('userSignup')

tracker.getApiKey = (data)->
  trackEvent('getApiKey', data)

tracker.logIn = (currentUser)->
  tracker.userSignup() if currentUser.isNew()

tracker.load = ->
  tracker.ga = ga if typeof ga isnt 'undefined'

# for testing
tracker.unload = ->
  delete tracker.ga
