copyFile = Cine.require('test/helpers/copy_file')
gzipFile = Cine.require('test/helpers/gzip_file')
edgecastFtpClientFactory = Cine.server_lib('edgecast_ftp_client_factory')
_ = require('underscore')
writeExampleFmsFile = (outputStream, callback)->
  fmsExampleLog = Cine.path('test/fixtures/edgecast_logs/fms_example.log')
  unZipFile = outputStream.path.slice(0, outputStream.path.length-3)
  console.log('writing fake faile to', unZipFile)
  copyFile fmsExampleLog, unZipFile, (err)->
    expect(err).to.be.undefined
    gzipFile.replaceFile unZipFile, (err)->
      expect(err).to.be.undefined
      callback()

class FakeFtpStream
  constructor: (@name, @events={})->
  once: (event, callback)->
    @events[event] = callback
  trigger: (event, args)->
    @events[event](args)
  pipe: (outputStream)->
    @trigger("readable")
    writeExampleFmsFile outputStream, (err)=>
      @trigger("close")

module.exports = class FakeFtpClient
  constructor: (@events={})->
    @stubs = []
    @connectStub = @stub('connect')
    @builderStub = sinon.stub edgecastFtpClientFactory, 'builder'
    @builderStub.returns(this)

  stub: (functionName)->
    stub = sinon.stub this, functionName
    @stubs.push(stub)
    stub

  start: ->
    process.nextTick =>
      @trigger('ready')

  restore: ->
    @builderStub.restore()
    _.invoke(@stubs, 'restore')

  on: (event, callback)->
    @events[event] = callback
  connect: ->
  list: ->
  get: (name, callback)->
    ftpStream = new FakeFtpStream(name)
    process.nextTick ->
      callback(null, ftpStream)
  end: ->
    @trigger('end')
  trigger: (event, args)->
    @events[event](args)
