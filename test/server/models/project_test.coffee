Project = Cine.server_model('project')
BackboneProject = Cine.model('project')
_ = require('underscore')
modelTimestamps = Cine.require('test/helpers/model_timestamps')

describe 'Project', ->
  modelTimestamps(Project, name: 'hey', plan: 'free')

  describe 'validations', ->
    describe 'plan', ->
      _.each BackboneProject.plans, (plan)->
        it "can be #{plan}", (done)->
          project = new Project(name: 'some name', plan: plan)
          project.save (err, member)->
            done(err)
      it 'can be test', (done)->
        project = new Project(name: 'some name', plan: 'test')
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

  describe 'publicKey', ->
    it 'has a unique publicKey generated on save', (done)->
      project = new Project(name: 'some name', plan: 'free')
      project.save (err)->
        expect(err).to.be.null
        expect(project.publicKey.length).to.equal(32)
        done()

    it 'will not override the password change request on future saves', (done)->
      project = new Project(name: 'some name', plan: 'free')
      project.save (err)->
        expect(err).to.be.null
        publicKey = project.publicKey
        expect(publicKey.length).to.equal(32)
        project.save (err)->
          expect(project.publicKey).to.equal(publicKey)
          done(err)

  describe 'secretKey', ->
    it 'has a unique secretKey generated on save', (done)->
      project = new Project(name: 'some name', plan: 'free')
      project.save (err)->
        expect(err).to.be.null
        expect(project.secretKey.length).to.equal(32)
        done()

    it 'will not override the password change request on future saves', (done)->
      project = new Project(name: 'some name', plan: 'free')
      project.save (err)->
        expect(err).to.be.null
        secretKey = project.secretKey
        expect(secretKey.length).to.equal(32)
        project.save (err)->
          expect(project.secretKey).to.equal(secretKey)
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
