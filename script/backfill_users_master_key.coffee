require('coffee-script')
environment = require('../config/environment')
GS = require '../config/giving_stage'
async = require('async')
User = GS.server_model('user')

setMasterKey = (user, callback)->
  crypto.randomBytes 32, (ex, buf)->
    user.masterKey = buf.toString('hex')
    user.save callback

query =
  masterKey: {$exists: false}

endFunction = (err)->
  console.log('the end', err)
  process.exit(0)

processUsers = (err, users)->
  return endFunction(err) if err

  console.log("backfilling #{users.length} users")

  async.each users, setMasterKey, endFunction

User.find query, processUsers
