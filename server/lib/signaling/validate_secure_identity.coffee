debug = require('debug')('cine:validate_secure_identity')
crypto = require('crypto')

generateExpectedSignature = (identity, timestamp, secretKey)->
  shasum = crypto.createHash('sha1')

  signatureToSha = "identity=#{identity}&timestamp=#{timestamp}#{secretKey}"

  shasum.update(signatureToSha)
  shasum.digest('hex')


module.exports = (identity, secretKey, timestamp, actualSignature)->
  expectedSignature = generateExpectedSignature(identity, timestamp, secretKey)
  # debug expectedSignature, actualSignature
  expectedSignature == actualSignature
