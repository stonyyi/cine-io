responseXML = Cine.server_lib('appdirect/response_xml')

module.exports = (res, responseXMLMethod, args...)->
  res.set('Content-Type', 'text/xml')
  appdirectResponse = responseXML[responseXMLMethod](args...)
  # console.log("sending appdirect response", appdirectResponse)
  return res.send(appdirectResponse)
