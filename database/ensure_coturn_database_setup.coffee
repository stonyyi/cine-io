environment = require('../config/environment')
Cine.config('connect_to_mongo')
async = require('async')

Realm = Cine.server_model('realm')
TurnUser = Cine.server_model('turn_user')

endFunction = (err)->
  if err
    console.log("DONE ERR", err)
    process.exit(1)
  console.log("DONE")
  process.exit()

CONSTANTS =
  kurentoUser: 'Kurento'
  kurentoPassword: 'Cwznt7Nt9haJRwfYMKXxZZM8DNctGnEytGCCXCcJkwpdZhXXnG'

asyncCalls =
  createRealm: (cb)->
    Realm.findOrCreate realm: Realm.HARD_CODED_REALM_SAME_AS_TURN_SERVER, cb
  createKurentoTurnUser: (cb)->
    tu = new TurnUser(name: CONSTANTS.kurentoUser)
    tu.setHmackey(CONSTANTS.kurentoPassword)
    attributes =
      name: tu.name
      hmackey: tu.hmackey
    TurnUser.findOrCreate attributes, cb

async.parallel asyncCalls, endFunction
