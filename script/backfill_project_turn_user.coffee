environment = require('../config/environment')
Cine.config('connect_to_mongo')
Project = Cine.server_model('project')
require "mongoose-querystream-worker"
createTurnUserForProject = Cine.server_lib('coturn/create_turn_user_for_project')

backfillProjectTurnPassword = (project, callback)->
  console.log('backfill turn user for', project._id)
  createTurnUserForProject project, callback

endFunction = (err)->
  console.log('the end', err)
  process.exit(0)

scope = Project.find()

scope.stream().concurrency(20).work backfillProjectTurnPassword, endFunction
