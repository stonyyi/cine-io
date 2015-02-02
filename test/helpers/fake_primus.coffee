class PrimusScope
  constructor: ->
    sinon.spy this, 'room'
    sinon.spy this, 'except'
    sinon.spy this, 'write'
  room: (@roomParam)->
    @_ensureNotWritten()
    return this
  except: (@exceptParam)->
    @_ensureNotWritten()
    return this
  write: (@writeParam)->
    return this
  _ensureNotWritten: ->
    throw new Error("Cannot chain to written scope") if @writeParam

module.exports = class Primus
  constructor: ->
    sinon.spy this, 'room'
    sinon.spy this, 'except'
    sinon.spy this, 'write'

  room: (roomName)->
    (new PrimusScope()).room(roomName)
  except: (data)->
    (new PrimusScope()).except(data)
  write: (data)->
    (new PrimusScope()).write(data)
