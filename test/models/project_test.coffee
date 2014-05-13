Project = Cine.model('project')
modelTimestamps = Cine.require('test/helpers/model_timestamps')

describe 'Project', ->
  modelTimestamps(Project, name: 'hey')

  describe 'api_key', ->
    it 'has a unique api_key generated on save', (done)->
      project = new Project(name: 'some name')
      project.save (err)->
        expect(err).to.be.null
        expect(project.apiKey.length).to.equal(32)
        done()

    it 'will not override the password change request on future saves', (done)->
      project = new Project(name: 'some name')
      project.save (err)->
        expect(err).to.be.null
        apiKey = project.apiKey
        expect(apiKey.length).to.equal(32)
        project.save (err)->
          expect(project.apiKey).to.equal(apiKey)
          done(err)
