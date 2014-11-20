_ = require('underscore')
AWS = Cine.server_lib('aws/aws')

cloudfront = new AWS.CloudFront()
createCloudfrontParams = Cine.server_lib("aws/create_cloudfront_params")

exports.createDistribution = (origin, options={}, callback)->
  if typeof options == 'function'
    callback = options
    options = {}
  cloudfrontParams = createCloudfrontParams(origin, options)

  cloudfront.createDistribution cloudfrontParams, callback

exports.getDistribution = (id, callback)->
  cloudfrontParams =
    Id: id
  cloudfront.getDistribution cloudfrontParams, callback
