s3 = require('s3')
_ = require('underscore')
s3Credentials = Cine.config('variables/s3')

s3Client = s3.createClient
  maxAsyncS3: 20                     # this is the default
  s3RetryCount: 3                    # this is the default
  s3RetryDelay: 1000                 # this is the default
  multipartUploadThreshold: 20971520 # this is the default (20 MB)
  multipartUploadSize: 15728640      # this is the default (15 MB)
  s3Options: s3Credentials

module.exports = (localFile, bucket, remoteFile, options={}, callback)->
  if typeof options == 'function'
    callback = options
    options = {}
  _.defaults(options, ACL: 'public-read')
  params =
    localFile: localFile
    s3Params:
      Bucket: bucket
      Key: remoteFile
      ACL: options.ACL

  # console.log("uploading", params)

  uploader = s3Client.uploadFile(params)

  uploader.on 'error', (err)->
    console.error("unable to upload:", err)
    callback(err)

  # uploader.on 'progress', ->
  #   console.log("progress", uploader.progressMd5Amount, uploader.progressAmount, uploader.progressTotal)

  uploader.on 'end', ->
    # console.log("done uploading")
    callback()

module.exports._s3Client = s3Client
