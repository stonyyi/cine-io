debug = require('debug')('cine:send_appdirect_response')
responseXML = Cine.server_lib('appdirect/response_xml')

module.exports = (res, responseXMLMethod, args...)->
  res.set('Content-Type', 'text/xml')
  appdirectResponse = responseXML[responseXMLMethod](args...)
  # debug("sending appdirect response", appdirectResponse)
  return res.send(appdirectResponse)
