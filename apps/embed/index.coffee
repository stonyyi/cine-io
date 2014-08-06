express = require('express')
fs = require('fs')
module.exports = app = express()

console.log('loaded')
fileName = __dirname + "/index.html"

app.get '/:publicKey/:steramId', (req, res)->
  readStream = fs.createReadStream(fileName)
  res.set('Content-Type', 'text/html')
  readStream.pipe(res)
