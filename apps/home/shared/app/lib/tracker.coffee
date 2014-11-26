_ = require('underscore')
isServer = typeof window is 'undefined'
namespace = if isServer then global else window

tracker = exports
tracker.preventTracking = isServer

trackGoogleAnalytics = (eventName, data)->
  # ga will change from an array to the actual ga
  # underneath us, and there's no way of knowing when that happens
  tracker.ga = namespace.ga if tracker.ga != namespace.ga
  return unless tracker.ga
  gaOptions =
    hitType: 'event'       # Required.
    eventCategory: 'KPI'   # Required.
    eventAction: eventName # Required.
  gaOptions.eventValue = data.value if data.value
  ga 'send', gaOptions

trackMixpanel = (eventName, data)->
  return unless tracker.mixpanel
  tracker.mixpanel.track(eventName, data)

trackEvent = (eventName, data={}, options={})->
  throw new Error("cannot track events on server") if tracker.preventTracking
  console.log('tracking', eventName, data)
  trackGoogleAnalytics(eventName, data) unless options.noGA
  trackMixpanel(eventName, data) unless options.noMixpanel

tracker.userSignup = ->
  trackEvent('userSignup')

tracker.addedCard = ->
  trackEvent('addedCard')

tracker.getApiKey = (data)->
  trackEvent('getApiKey', data)

tracker.startedDemo = ->
  trackEvent('startedDemo', {}, noGA: true)

tracker.planChange = (newPlan)->
  trackEvent('planChange', {plan: newPlan}, noGA: true)

tracker.logIn = (currentUser)->
  identify(currentUser)
  updateMixpanelPerson(currentUser)
  if currentUser.isNew()
    tracker.userSignup()

updateMixpanelPerson = (currentUser)->
  data = $email: currentUser.get('email'), $name: currentUser.get('name')
  console.log('setting mixpanel data', data)
  tracker.mixpanel.people.set(data)

identify = (currentUser)->
  return unless tracker.mixpanel
  userId = currentUser.id
  return if alreadyAliased(currentUser)
  if currentUser.isNew()
    tracker.mixpanel.alias(userId)
    tracker.mixpanel.identify(userId)
  else
    console.log('identify', userId)
    tracker.mixpanel.identify(userId)

alreadyAliased = (currentUser)->
  tracker.mixpanel && tracker.mixpanel.get_property && tracker.mixpanel.get_property('__alias') == currentUser.id

tracker.logOut = ->
  tracker.mixpanel.cookie.clear() if tracker.mixpanel && tracker.mixpanel.cookie

tracker.load = ->
  tracker.mixpanel = mixpanel if typeof mixpanel isnt 'undefined'
  tracker.ga = ga if typeof ga isnt 'undefined'

# for testing
tracker.unload = ->
  delete tracker.ga
