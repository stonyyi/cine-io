_ = require('underscore')
AWS = Cine.server_lib('aws/aws')

cloudfront = new AWS.CloudFront()
createCloudfrontParams = Cine.server_lib("aws/create_cloudfront_params")

distributionIsDeployed = (distribution)->
  distribution.Status == 'Deployed'

exports.ensureDistributionForOrigin = (origin, options={}, callback)->
  if typeof options == 'function'
    callback = options
    options = {}

  # waitForDistributionToBeDeployed(null, callback)
  exports.distrubtionForOrigin origin, (err, distribution)->
    # console.log("FOUND DISTRO", distribution)
    if distribution
      return callback(null, distribution) if distributionIsDeployed(distribution)
      waitForDistributionToBeDeployed(distribution, callback)
    else
      # callback()
      createAndWaitForDistribution(origin, options, callback)

exports.distrubtionForOrigin = (origin, callback)->
  exports.listDistributions (err, response)->
    return callback(err) if err
    # console.log("GOT RESPONSE", response)
    distribution = findDistributionForOrigin(origin, response.Items)
    callback(null, distribution)

createAndWaitForDistribution = (origin, options, callback)->
  exports.createDistribution origin, options, (err, distribution)->
    return callback(err) if err
    waitForDistributionToBeDeployed(distribution, callback)

waitForDistributionToBeDeployed = (distribution, callback)->
  cloudfront.waitFor 'distributionDeployed', Id: distribution.Id, (err, distro)->
    # console.log("DONE", err, distro)
    callback(err, distro)

findDistributionForOrigin = (origin, response)->
  _.find response, (distribution)->
    # console.log("SEARCHING distribution", distribution)
    return false if distribution.Origins.Quantity == 0
    _.any distribution.Origins.Items, (distroOrigin)->
      # console.log("SEARCHING distroOrigin", distroOrigin)
      distroOrigin.DomainName == origin

# callback(err, res)
# http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/CloudFront.html#listDistributions-property
exports.listDistributions = (params={}, callback)->
  if typeof params == 'function'
    callback = params
    params = {}
  callback
  cloudfront.listDistributions params, callback

# callback(err, res)
exports.createDistribution = (origin, options={}, callback)->
  if typeof options == 'function'
    callback = options
    options = {}
  cloudfrontParams = createCloudfrontParams(origin, options)
  cloudfront.createDistribution cloudfrontParams, callback

# callback(err, res)
exports.getDistribution = (id, callback)->
  cloudfrontParams =
    Id: id
  cloudfront.getDistribution cloudfrontParams, callback