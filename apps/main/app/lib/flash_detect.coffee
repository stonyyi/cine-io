isServer = typeof window is 'undefined'

module.exports =->
  return false if isServer
  hasFlash = false
  try
    fo = new ActiveXObject("ShockwaveFlash.ShockwaveFlash")
    hasFlash = true  if fo
  catch e
    hasFlash = true  if navigator.mimeTypes and navigator.mimeTypes["application/x-shockwave-flash"] isnt undefined and navigator.mimeTypes["application/x-shockwave-flash"].enabledPlugin

  hasFlash
