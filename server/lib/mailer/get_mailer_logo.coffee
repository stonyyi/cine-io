fs = require('fs')
module.exports = (callback)->
  fs.readFile "#{Cine.root}/server/lib/mailer/assets/mailer-logo.png", (err, logoFile)->
    return callback(err) if err
    callback null, logoFile.toString('base64')
