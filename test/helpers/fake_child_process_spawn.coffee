stream = require('stream')
debug = require('debug')('cine:fake_child_process_spawn')

class FakeOutputStream extends stream.Readable
  _read: ->
    return "HEY"
class FakeInputStream extends stream.Writable
  _write: (chunk)->
    debug("GOT CHUNK", chunk)

module.exports = class FakeSpawn
  constructor: ->
    @stderr = new FakeOutputStream
    @stdin = new FakeInputStream
    @callbacks = {}
    sinon.spy this, 'on'
    sinon.spy this, 'kill'
  on: (event, callback)->
    @callbacks[event] = callback
  trigger: (event, args...)->
    @callbacks[event](args...) if @callbacks[event]
  kill: (term, args...)->
    @trigger('close', args...)
