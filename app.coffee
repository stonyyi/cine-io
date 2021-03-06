env     = require './config/environment'

switch process.env.RUN_AS
  when 'hls'
    app = Cine.app('m3u8')
  when 'signaling'
    app = Cine.app('signaling')
  when 'rtc_transmuxer'
    app = Cine.app('rtc_transmuxer')
  else
    app = Cine.app('home')

if app
  app.use Cine.middleware('error_handling')
  exports.app = app
  if process.env.SSL_CERTS_PATH
    https = require('https')
    fs = require('fs')
    sslCertsPath = process.env.SSL_CERTS_PATH
    sslCertFile = "localhost-cine-io.crt"
    sslKeyFile = "localhost-cine-io.key"
    sslIntermediateCertFiles = [ "COMODORSADomainValidationSecureServerCA.crt", "COMODORSAAddTrustCA.crt", "AddTrustExternalCARoot.crt" ]
    sslKey = fs.readFileSync("#{sslCertsPath}/#{sslKeyFile}")
    sslCert = fs.readFileSync("#{sslCertsPath}/#{sslCertFile}")
    sslCA = (fs.readFileSync "#{sslCertsPath}/#{file}" for file in sslIntermediateCertFiles)
    options =
      ca: sslCA
      cert: sslCert
      key: sslKey
      requestCert: true
      rejectUnauthorized: false
      agent: false
    exports.server = https.createServer(options, app)
  else
    http = require('http')
    exports.server = http.createServer(app)

switch process.env.RUN_AS
  when 'signaling'
    Cine.require('apps/signaling/start_primus', exports.server)
  when 'rtc_transmuxer'
    Cine.require('apps/rtc_transmuxer/start_primus', exports.server)
