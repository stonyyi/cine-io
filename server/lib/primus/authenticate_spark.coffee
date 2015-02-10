Project = Cine.server_model('project')
noop = ->
callMe = (cb)->
  cb()

projectForPublicKey = (publicKey, callback)->
  projectParams = publicKey: publicKey
  Project.findOne projectParams, (err, project)->
    return callback(err) if err
    unless project
      console.error("COULD NOT FIND PROJECT", publicKey)
      return callback("project not found")
    callback(null, project)

exports.authenticateSpark = (spark, data, callback=noop)->
  publicKey = data.publicKey
  projectForPublicKey publicKey, (err, project)->
    if err || !project
      callback('invalid public key')
      if spark.projectCallbacks
        _.each spark.projectCallbacks, (cb)->
          cb("invalid public key")
      return spark.end exports.invalidPublicKeyOptions(publicKey)
    spark.projectId = project._id
    spark.secretKey = project.secretKey
    spark.signalingClient = data.client
    spark.write action: 'ack', source: 'auth'
    callback(null, project)
    if spark.projectCallbacks
      spark.projectCallbacks.forEach callMe
      delete spark.projectCallbacks

exports.ensureProjectId = (spark, callback)->
  return process.nextTick(callback) if spark.projectId
  spark.projectCallbacks ||= []
  spark.projectCallbacks.push(callback)

exports.invalidPublicKeyOptions = (publicKey)->
  action: 'error', error: "INVALID_PUBLIC_KEY", message: "invalid publicKey: #{publicKey} provided"
