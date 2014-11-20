AWS = require('aws-sdk')
s3 = Cine.config('variables/s3')
AWS.config.update(accessKeyId: s3.accessKeyId, secretAccessKey: s3.secretAccessKey)

module.exports = AWS
