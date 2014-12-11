TurnUser = Cine.server_model('turn_user')

module.exports = (project, callback)->
  return callback("no turnPassword set") unless project.turnPassword
  tu = new TurnUser(name: project.publicKey, _project: project._id)
  tu.setHmackey(project.turnPassword)
  tu.save callback
