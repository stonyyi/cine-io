verifyOauthSignature = Cine.server_lib('appdirect/verify_oauth_signature')

module.exports = (req)->
  fullUrl = "#{req.protocol}://#{req.hostname}#{req.path}"
  authorization = req.headers['authorization']
  return false unless authorization
  verifyOauthSignature(authorization, fullUrl, req.query, req.method)
