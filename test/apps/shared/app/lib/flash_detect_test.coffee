flashDetect = Cine.lib('flash_detect')

describe 'flashDetect', ->

  it 'returns false on the server', ->
    expect(flashDetect()).to.be.false

  describe '_clientTest', ->
    describe "ActiveXObject", ->
      beforeEach ->
        global.ActiveXObject = class
          constructor: (value)->
            expect(value).to.equal("ShockwaveFlash.ShockwaveFlash")
      afterEach ->
        delete global.ActiveXObject

      it 'returns true when there is an ActiveXObject class', ->
        expect(flashDetect._clientTest()).to.be.true
    describe 'navigator support', ->
      beforeEach ->
        global.navigator = {}
      afterEach ->
        delete global.navigator

      it 'returns false when the navigator does not support specific mime types', ->
        expect(flashDetect._clientTest()).to.be.false

      it 'returns false when the navigator does not support application/x-shockwave-flash', ->
        navigator.mimeTypes = {}
        expect(flashDetect._clientTest()).to.be.false

      it 'returns false when the navigator supports application/x-shockwave-flash but there is no information', ->
        navigator.mimeTypes = {}
        navigator.mimeTypes['application/x-shockwave-flash'] = true
        expect(flashDetect._clientTest()).to.be.false

      it 'returns false when the navigator supports application/x-shockwave-flash but it is not enabled', ->
        navigator.mimeTypes = {}
        navigator.mimeTypes['application/x-shockwave-flash'] = {enabledPlugin: false}
        expect(flashDetect._clientTest()).to.be.false

      it 'returns true when the navigator supports application/x-shockwave-flash', ->
        navigator.mimeTypes = {}
        navigator.mimeTypes['application/x-shockwave-flash'] = {enabledPlugin: true}
        expect(flashDetect._clientTest()).to.be.true

    it 'otherwise returns false', ->
      expect(flashDetect._clientTest()).to.be.false

# isServer = typeof window is 'undefined'

# module.exports = ->
#   return false if isServer
#   hasFlash = false
#   try
#     fo = new ActiveXObject("ShockwaveFlash.ShockwaveFlash")
#     hasFlash = true  if fo
#   catch e
#     hasFlash = true  if navigator.mimeTypes and navigator.mimeTypes["application/x-shockwave-flash"] isnt undefined and navigator.mimeTypes["application/x-shockwave-flash"].enabledPlugin

#   hasFlash
