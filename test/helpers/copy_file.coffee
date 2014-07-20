fs = require('fs')

module.exports = (source, target, cb) ->

  done = (err) ->
    cb err unless cbCalled
    cbCalled = true

  cbCalled = false

  rd = fs.createReadStream(source)
  rd.on "error", (err) ->
    done err

  wr = fs.createWriteStream(target)
  wr.on "error", (err) ->
    done err

  wr.on "close", (ex) ->
    done()

  rd.pipe wr
