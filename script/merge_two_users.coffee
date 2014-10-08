environment = require('../config/environment')
Cine.config('connect_to_mongo')
User = Cine.server_model('user')
_ = require('underscore')
mongoose = require('mongoose')

endFunction = (err, aggregate)->
  if err
    console.log("ending err", err)
    process.exit(1)
  process.exit(0)

stringify = (item)->
  item.toString()

mergeUsers = (userToKeep, userToDestroy, callback)->
  userToKeep._accounts = _.uniq(userToKeep._accounts.concat(userToDestroy._accounts), stringify)

  # github data
  userToKeep.githubId ||= userToDestroy.githubId
  userToKeep.githubAccessToken ||= userToDestroy.githubAccessToken
  userToKeep.githubData = userToDestroy.githubData if _.isEmpty(userToKeep.githubData)

  userToKeep.hashed_password ||= userToDestroy.hashed_password
  userToKeep.password_salt ||= userToDestroy.password_salt
  userToKeep.isSiteAdmin ||= userToDestroy.isSiteAdmin

  console.log("after", userToKeep)
  console.log("destroying", userToDestroy)
  if mongoose.connections[0].user == 'readonly'
    console.log("read only connection, exiting")
    return callback()

  userToKeep.save (err, user)->
    return callback(err) if err
    console.log("saved!")
    userToDestroy.remove (err, user)->
      return callback(err) if err
      console.log("destroyed!")
      callback()

# arbitrary keep/destroy
userToKeepId = ""
userToDestroyId = ""

User.findOne _id: userToKeepId, (err, userToKeep)->
  return endFunction(err) if err
  return endFunction("userToKeep not found") unless userToKeep
  User.findOne _id: userToDestroyId, (err, userToDestroy)->
    return endFunction(err) if err
    return endFunction("userToDestroy not found") unless userToDestroy
    mergeUsers(userToKeep, userToDestroy, endFunction)
