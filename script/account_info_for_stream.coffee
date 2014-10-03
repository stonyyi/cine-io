environment = require('../config/environment')
Cine = require '../config/cine'
EdgecastStream = Cine.server_model('edgecast_stream')
Project = Cine.server_model("project")
Account = Cine.server_model("account")


streamName = "STREAM_NAME"

query =
  streamName: streamName

findByStreamName = (callback)->
  EdgecastStream.findOne query, (err, stream)->
    return callback(err) if err
    console.log('found stream', stream)
    Project.findById stream._project, (err, project)->
      return callback(err) if err
      console.log('found project', project)
      Account.findById project._account, (err, account)->
        return callback(err) if err
        console.log('found account', account)
        callback()

done = (err)->
  if err
    console.log("DONE ERR", err)
    process.exit(1)
  process.exit()

return done("PLEASE SET STREAM NAME") if streamName == "STREAM_NAME"
findByStreamName done
