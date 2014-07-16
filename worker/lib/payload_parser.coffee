# https://github.com/iron-io/iron_worker_examples/blob/edcf9c69f78577065d22571516535444ce0fbf12/node/worker101/lib/payload_parser.js
fs = require("fs")

parse_payload = (args, callback)->
  payloadIndex = -1
  args.forEach (val, index, array) ->
    payloadIndex = index + 1  if val is "-payload"

  return callback "No payload argument" if payloadIndex is -1
  return callback "No payload value" if payloadIndex >= args.length

  payloadFile = args[payloadIndex]
  fs.readFile payloadFile, "ascii", (err, data) ->
    return callback(err) if err
    callback null, JSON.parse(data)

module.exports = parse_payload
