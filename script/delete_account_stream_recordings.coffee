# heroku run --app=cine-io coffee script/delete_account_stream_recordings.coffee BILLING_EMAIL
require('coffee-script/register')

environment = require('../config/environment')
Cine.config('connect_to_mongo')
async = require('async')
und = require('underscore')

endFunction = (err, aggregate)->
  if err
    console.log("ending err", err)
    process.exit(1)
  process.exit(0)

EdgecastStream = Cine.server_model('edgecast_stream')
deleteStreamRecordingOnS3 = Cine.server_lib('stream_recordings/delete_stream_recording_on_s3')
StreamRecordings = Cine.server_model('stream_recordings')
Project = Cine.server_model('project')
Account = Cine.server_model('account')

accountQuery =
  billingEmail: process.argv[2] || 'BILLING_EMAIL'

numbers =
  projects: 0
  edgecastStreams: 0
  streamRecordings: 0

deleteProjectStreamRecordings = (project, callback)->
  deleteAllStreamRecording = (stream, cb)->
    StreamRecordings.findOne _edgecastStream: stream.id, (err, recordings)->
      unless recordings
        console.log("no recordings for", stream.id)
        return cb()
      deleteRecording = (recording, cb2)->
        return cb2() if recording.deletedAt
        console.log("deleting", recording.name, stream.id, project.id)
        numbers.streamRecordings += 1
        deleteStreamRecordingOnS3 project, recording.name, (err)->
          return cb2(err, null, status: 400) if err
          deletedAt = new Date
          recording.deletedAt = deletedAt
          recordings.save (err)->
            return cb2(err, null, status: 400) if err
            cb2(null, deletedAt: deletedAt)

      async.each recordings.recordings, deleteRecording, cb

  EdgecastStream.find _project: project._id, (err, streams)->
    numbers.edgecastStreams += streams.length
    async.each streams, deleteAllStreamRecording, callback

Account.findOne accountQuery, (err, account)->
  account.projects (err, projects)->
    numbers.projects = projects.length
    async.each projects, deleteProjectStreamRecordings, endFunction
