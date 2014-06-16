basicModel = Cine.require 'test/helpers/basic_model'
basicModel('stream', urlAttributes: ['id', 'secretKey'])
Stream = Cine.model('stream')

describe 'Stream', ->
  describe 'assignedAt', ->
    it 'returns a date', ->
      u = new Stream(assignedAt: (new Date).toISOString())
      expect(u.assignedAt()).to.be.instanceOf(Date)

    it 'returns null when unavailable', ->
      e = new Stream()
      expect(e.assignedAt()).to.be.null
