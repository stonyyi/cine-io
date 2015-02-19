debug = require('debug')('cine:delete_stream_recording_on_s3')
s3Client = Cine.server_lib('aws/s3_client')
VOD_BUCKET = Cine.config('variables/s3').vodBucket

module.exports = (project, recordingName, done)->
  path = "cines/#{project.publicKey}/#{recordingName}"
  debug("Deleting", path)
  s3Client.delete VOD_BUCKET, path, done
