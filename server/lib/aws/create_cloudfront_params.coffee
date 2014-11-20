shortId = require('shortid')
_ = require('underscore')

# caller reference is an indentifier
# that specifies a specific request
# it's like an ID for an api request
# make a unique name
createCallerReference = ->
  shortId.generate()

defaultViewerCert =
  CloudFrontDefaultCertificate: true
  MinimumProtocolVersion: 'TLSv1'
  SSLSupportMethod: 'sni-only'

defaultRestrictions =
  GeoRestriction: # required
    Quantity: 0 # required
    RestrictionType: 'none' # required
    Items: []

defaultCustomErrorResponses =
  Quantity: 0 # required
  Items: []

defaultMethods =
  Quantity: 2 # required
  Items: ['GET', 'HEAD'] # required
  CachedMethods:
    Quantity: 2 # required
    Items: [ 'GET', 'HEAD' ] # required

defaultTrustedSigners =
  Enabled: false # required
  Quantity: 0 # required
  Items: []

defaultForwardValues =
  Cookies: # required
    Forward: 'none' # required
    WhitelistedNames:
      Quantity: 0# required
      Items: []
  QueryString: false # required
  Headers:
    Quantity: 0 # required
    Items: []

defaultAliases =
  # required
  Quantity: 0, # required
  Items: []

defaultCacheBehavior =
  Quantity: 0 # required
  Items: []

defaultOriginConfig =
  HTTPPort: 80, # required
  HTTPSPort: 443, # required
  OriginProtocolPolicy: 'match-viewer' # required

loggingOff =
  Bucket: '' # required
  Enabled: false # required
  IncludeCookies: false # required
  Prefix: '' # required

generateLogging = (options)->
  # required
  return loggingOff unless options.logging.bucket
  ret =
    Bucket: options.logging.bucket, # required
    Enabled: true # required
    IncludeCookies: false # required
    Prefix: options.logging.prefix # required

module.exports = (origin, options={})->
  _.defaults(options, logging: {}, enabled: true, comment: '')
  originId = "Custom-#{origin}"
  params =
    DistributionConfig: # required
      Aliases: defaultAliases
      CacheBehaviors: defaultCacheBehavior # required
      CallerReference: createCallerReference() # required
      Comment: options.comment, # required
      DefaultCacheBehavior: # required
        ForwardedValues: defaultForwardValues   # required
        MinTTL: 0 # required
        TargetOriginId: originId # required
        TrustedSigners: defaultTrustedSigners # required
        ViewerProtocolPolicy: 'allow-all', # required
        AllowedMethods: defaultMethods
        SmoothStreaming: false
      DefaultRootObject: '', # required
      Enabled: options.enabled # required
      Logging: generateLogging(options)
      Origins: # required
        Quantity: 1 # required
        Items: [
          {
            DomainName: origin, # required
            Id: originId, # required
            CustomOriginConfig: defaultOriginConfig
          }
        ]
      PriceClass: 'PriceClass_All', # required
      CustomErrorResponses: defaultCustomErrorResponses
      Restrictions: defaultRestrictions
      ViewerCertificate: defaultViewerCert

  return params
