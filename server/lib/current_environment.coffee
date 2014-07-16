module.exports = (payload, callback)->
  now = new Date
  output =
    payload: payload
    TZ: process.env.TZ
    NODE_ENV: process.env.NODE_ENV
    currentTime: now.toString()
  callback(null, output)
