async = require('async')
request = require('request')
_ = require('underscore')
clc = require "cli-color"
startTime = new Date

prefixes = ["http://", "http://www.", "https://", "https://www."]
expectedUrl = "https://www.cine.io/health"
allowedDowntime = 15 # seconds
acceptableTimeout = 5 # seconds

newSha = process.env.CIRCLE_SHA1.substr(0,7)

checkUrl = (url)->
  (callback)->
    request.get url, timeout: acceptableTimeout*1000, validateUrlResponse(url, callback)

validateUrlResponse = (url, callback)->
  (err, res)->
    if err
      console.log(clc.red(url), err)
      callback(err)
    else if res.body == 'OK'
      actualUrl = res.request.uri.href
      if actualUrl == expectedUrl
        console.log clc.green(url)
        callback(null)
      else
        console.log clc.red(url), actualUrl
        callback('not equal')
    else
      console.log clc.red(url)
      callback('not ok body')

functionsToCall = _.map prefixes, (prefix)->
  url = "#{prefix}cine.io/health"
  checkUrl(url)

checkErr = (success)->
  (err)->
    if err
      console.log(err)
      return process.exit(1)

    return success()

checkUrls = (err)->
  console.log('checking urls')
  async.parallel functionsToCall, checkErr(process.exit)

newCodeUp = false
firstCheck = true


console.log('waiting for sha', newSha)
newCodeDeployed = ->
  console.log('siteup', newCodeUp) unless firstCheck
  firstCheck = false
  newCodeUp

checkFunction = (callback)->
  request.get "https://www.cine.io/deployinfo", (err, res)->
    currentSha = !err && res && res.statusCode == 200 && JSON.parse(res.body).sha
    console.log('deployed sha', currentSha)

    newCodeUp = currentSha == newSha
    unless newCodeUp
      now = new Date
      downtime = (now - startTime) / 1000
      console.log("New code not deployed for #{downtime} seconds")
    if downtime > allowedDowntime
      callback("Not deployed in #{allowedDowntime} seconds")
    else
      callback()

async.until newCodeDeployed, checkFunction, checkErr(checkUrls)
