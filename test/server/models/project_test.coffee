Project = Cine.server_model('project')
modelTimestamps = Cine.require('test/helpers/model_timestamps')

describe 'Project', ->
  modelTimestamps(Project, name: 'hey', plan: 'free')

  describe 'validations', ->
    describe 'plan', ->
      it 'can be free', (done)->
        project = new Project(name: 'some name', plan: 'free')
        project.save (err, member)->
          done(err)
      it 'can be developer', (done)->
        project = new Project(name: 'some name', plan: 'developer')
        project.save (err, member)->
          done(err)
      it 'cannot be anything else', (done)->
        project = new Project(name: 'some name', plan: 'something else')
        project.save (err, member)->
          expect(err).not.to.be.null
          done()

      it 'cannot be null', (done)->
        project = new Project(name: 'some name')
        project.save (err, member)->
          expect(err).not.to.be.null
          done()

  describe 'api_key', ->
    it 'has a unique api_key generated on save', (done)->
      project = new Project(name: 'some name', plan: 'free')
      project.save (err)->
        expect(err).to.be.null
        expect(project.apiKey.length).to.equal(32)
        done()

    it 'will not override the password change request on future saves', (done)->
      project = new Project(name: 'some name', plan: 'free')
      project.save (err)->
        expect(err).to.be.null
        apiKey = project.apiKey
        expect(apiKey.length).to.equal(32)
        project.save (err)->
          expect(project.apiKey).to.equal(apiKey)
          done(err)

  describe '.increment', ->
    beforeEach resetMongo
    it 'increments the specified field and returns the new attributes', (done)->
      project = new Project(name: 'a', streamsCount: 12, plan: 'free')
      project.save (err)->
        expect(err).to.be.null
        Project.increment project, 'streamsCount', 3, (err, newProjectAttributes)->
          expect(err).to.be.null
          expect(newProjectAttributes.name).to.equal('a')
          expect(newProjectAttributes.streamsCount).to.equal(15)
          done()

    it 'updates the existing model', (done)->
      project = new Project(name: 'a', streamsCount: 12, plan: 'free')
      project.save (err)->
        expect(err).to.be.null
        Project.increment project, 'streamsCount', 3, (err, newProjectAttributes)->
          expect(err).to.be.null
          expect(project.streamsCount).to.equal(15)
          Project.increment project, 'streamsCount', 2, (err, newProjectAttributes)->
            expect(err).to.be.null
            expect(project.streamsCount).to.equal(17)
          done()
