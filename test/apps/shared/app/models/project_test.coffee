basicModel = Cine.require 'test/helpers/basic_model'
basicModel('project', urlAttributes: ['publicKey'])
Project = Cine.model('project')

describe 'Project', ->
  describe 'getStreams', ->
    it 'is tested'
  describe 'updatedAt', ->
    it 'returns a date', ->
      u = new Project(updatedAt: (new Date).toISOString())
      expect(u.updatedAt()).to.be.instanceOf(Date)

    it 'returns null when unavailable', ->
      e = new Project()
      expect(e.updatedAt()).to.be.null
