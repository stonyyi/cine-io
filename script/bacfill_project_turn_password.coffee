environment = require('../config/environment')
Cine.config('connect_to_mongo')
Project = Cine.server_model('Project')
require "mongoose-querystream-worker"
crypto = require('crypto')

backfillProjectTurnPassword = (project, callback)->
  console.log('backfill plan for', project._id)
  crypto.randomBytes 16, (ex, buf)->
    project.turnPassword = buf.toString('hex')
    project.save callback

endFunction = (err)->
  console.log('the end', err)
  process.exit(0)

scope = Project.find()

scope.stream().concurrency(20).work backfillProjectTurnPassword, endFunction
