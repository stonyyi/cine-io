s3 = require('s3')
_ = require('underscore')
s3Credentials = Cine.config('variables/s3')

s3Client = s3.createClient
  maxAsyncS3: 20                     # this is the default
  s3RetryCount: 3                    # this is the default
  s3RetryDelay: 1000                 # this is the default
  multipartUploadThreshold: 20971520 # this is the default (20 MB)
  multipartUploadSize: 15728640      # this is the default (15 MB)
  s3Options: _.pick s3Credentials, 'accessKeyId', 'secretAccessKey'

exports.uploadFile = (localFile, bucket, remoteFile, options={}, callback)->
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

exports.downloadFile = (localFile, bucket, remoteFile, callback)->
  params =
    localFile: localFile
    s3Params:
      Bucket: bucket
      Key: remoteFile
  downloader = s3Client.downloadFile(params)
  downloader.on 'error', (err)->
    console.error("unable to download:", err.stack)
    callback(err)
  # downloader.on 'progress', ->
  #   console.log("progress", downloader.progressAmount, downloader.progressTotal)

  downloader.on 'end', ->
    # console.log("done downloading")
    callback()

# lister = list("bucket", 'hello/abc/')
# lister.on 'data', (data)-> console.log("got data")
# lister.on 'error', callback(err)
# lister.on 'end', callback
exports.list = (bucket, directory='')->
  params =
    s3Params:
      Bucket: bucket
      Prefix: directory
      Delimiter: '/'
  # console.log("Calling listObjects", params)
  lister = s3Client.listObjects(params)

fileNameToDeleteObject = (fileName)->
  Key: fileName
# delete("S3-BUCKET", "full/path/to/filea", "full/path/to/fileb", ..., callback)
exports.delete = (bucket, files..., callback)->
  params =
    Bucket: bucket
    Delete:
      Objects: _.map(files, fileNameToDeleteObject)

  # console.log("Calling deleteObjects", params)

  deleter = s3Client.deleteObjects(params)
  deleter.on 'error', (err)->
    console.error("unable to delete", err)
    callback(err)

  deleter.on 'end', ->
    # console.log("done uploading")
    callback()

exports._s3Client = s3Client
