Project = Cine.server_model('project')
User = Cine.server_model('user')
findOrCreateResourcesFromHeroku = Cine.server_lib('find_or_create_resources_from_heroku')
EdgecastStream = Cine.server_model('edgecast_stream')
stubEdgecast = Cine.require 'test/helpers/stub_edgecast'
assertEmailSent = Cine.require 'test/helpers/assert_email_sent'

describe 'findOrCreateResourcesFromHeroku', ->

  addProjectToUser = (user, callback)->
    project = new Project(name: "in test project")
    project.save (err, project)->
      return callback(err) if err
      user.permissions.push objectId: project._id, objectName: 'Project'
      user.save callback

  describe 'createProjectAndUser' , ->
    describe "with an existing user", ->
      beforeEach (done)->
        @user = new User(plan: 'test', herokuId: 'theheroku@heroku.com')
        @user.save done

      it 'returns an existing user with an existing project', (done)->
        addProjectToUser @user, (err, user)=>
          expect(err).to.be.null
          findOrCreateResourcesFromHeroku.createProjectAndUser 'theheroku@heroku.com', 'test', (err, user, project)=>
            expect(err).to.be.null
            expect(user._id.toString()).to.equal(@user._id.toString())
            expect(user.plan).to.equal("test")
            expect(project.name).to.equal("in test project")
            done()

      it 'creates a new project when the user does not have a project', (done)->
        findOrCreateResourcesFromHeroku.createProjectAndUser 'theheroku@heroku.com', 'test', (err, user, project)=>
          expect(err).to.be.null
          expect(user._id.toString()).to.equal(@user._id.toString())
          expect(project.name).to.equal("theheroku")
          done()

      it 'makes sure the user has the new plan', (done)->
        findOrCreateResourcesFromHeroku.createProjectAndUser 'theheroku@heroku.com', 'startup', (err, user, project)=>
          expect(err).to.be.null
          expect(user._id.toString()).to.equal(@user._id.toString())
          expect(user.plan).to.equal("startup")
          done()

      it 'undeletes a user', (done)->
        @user.deletedAt = new Date
        @user.save (err, user)=>
          expect(err).to.be.null
          expect(user.deletedAt).to.be.instanceOf(Date)
          findOrCreateResourcesFromHeroku.createProjectAndUser 'theheroku@heroku.com', 'startup', (err, user, project)=>
            expect(err).to.be.null
            expect(user._id.toString()).to.equal(@user._id.toString())
            expect(user.deletedAt).to.be.undefined
            done()

    describe "with a new user", ->

      assertEmailSent.admin "newUser"

      it 'sends a welcome email', (done)->
        findOrCreateResourcesFromHeroku.createProjectAndUser 'new-heroku-user@heroku.com', 'enterprise', (err, @user, @project)=>
          expect(@mailerSpies[0].firstCall.args[0].name).to.equal("new-heroku-user")
          expect(@mailerSpies[0].firstCall.args[1]).to.equal("heroku")
          done(err)

      describe "without a new stream", ->
        beforeEach (done)->
          findOrCreateResourcesFromHeroku.createProjectAndUser 'new-heroku-user@heroku.com', 'enterprise', (err, @user, @project)=>
            done(err)
        it 'creates a new user with permissions on the project', ->
          expect(@user.email).be.undefined
          expect(@user.name).to.equal("new-heroku-user")
          expect(@user.permissions).to.have.length(1)
          expect(@user.permissions[0].objectId.toString()).to.equal(@project._id.toString())
          expect(@user.permissions[0].objectName).to.equal("Project")

        it 'creates a new project', ->
          expect(@project).to.be.instanceOf(Project)
          expect(@project.name).to.equal("new-heroku-user")
          expect(@project.streamsCount).to.equal(0)
      describe 'with a new stream', ->
        stubEdgecast()

        beforeEach (done)->
          @stream = new EdgecastStream(streamName: 'name1')
          @stream.save(done)
        beforeEach (done)->
          findOrCreateResourcesFromHeroku.createProjectAndUser 'new-heroku-user@heroku.com', 'enterprise', (err, @user, @project)=>
            done(err)

        it 'adds a stream to that project', (done)->
          expect(@project.streamsCount).to.equal(1)
          EdgecastStream.find _project: @project._id, (err, streams)=>
            expect(err).to.be.null
            expect(streams).to.have.length(1)
            expect(streams[0]._id.toString()).to.equal(@stream._id.toString())
            done()

  describe 'findUser', ->
    beforeEach (done)->
      @user = new User(plan: 'test')
      @user.save done
    it 'finds a user by id', (done)->
      findOrCreateResourcesFromHeroku.findUser @user._id, (err, user)=>
        expect(err).to.be.null
        expect(user._id.toString()).to.equal(@user._id.toString())
        expect(user.plan).to.equal("test")
        done()
  describe 'updatePlan', ->
    beforeEach (done)->
      @user = new User(plan: 'test')
      @user.save done
    it "updates the user's plan", (done)->
      findOrCreateResourcesFromHeroku.updatePlan @user._id, "startup", (err, user)=>
        expect(err).to.be.null
        expect(user._id.toString()).to.equal(@user._id.toString())
        expect(user.plan).to.equal("startup")
        User.findById @user._id, (err, userFromDb)->
          expect(err).to.be.null
          expect(userFromDb.plan).to.equal('startup')
          done()
    it "undeletes a user", (done)->
      @user.deletedAt = new Date
      @user.save (err, user)=>
        expect(err).to.be.null
        expect(user.deletedAt).to.be.instanceOf(Date)
        findOrCreateResourcesFromHeroku.updatePlan @user._id, "startup", (err, user)=>
          expect(err).to.be.null
          expect(user._id.toString()).to.equal(@user._id.toString())
          expect(user.deletedAt).to.be.undefined
          User.findById @user._id, (err, userFromDb)->
            expect(err).to.be.null
            expect(user.deletedAt).to.be.undefined
            done()

  describe 'deleteUser', ->
    beforeEach (done)->
      @user = new User(plan: 'test')
      @user.save done

    it "adds deletedAt to a user", (done)->
      expect(@user.deletedAt).to.be.undefined
      findOrCreateResourcesFromHeroku.deleteUser @user._id, (err, user)=>
        expect(err).to.be.undefined
        expect(user._id.toString()).to.equal(@user._id.toString())
        expect(user.deletedAt).to.be.instanceOf(Date)
        User.findById @user._id, (err, userFromDb)->
          expect(err).to.be.null
          expect(userFromDb.deletedAt).to.be.instanceOf(Date)
          done()
