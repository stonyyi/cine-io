_ = require('underscore')
User = Cine.server_model('user')
modelTimestamps = Cine.require('test/helpers/model_timestamps')
BackboneUser = Cine.model('user')
Project = Cine.server_model('project')

describe 'User', ->
  modelTimestamps(User, email: 'hey', name: 'yo', plan: 'enterprise')

  describe 'validations', ->
    describe 'plan', ->
      _.each BackboneUser.plans, (plan)->
        it "can be #{plan}", (done)->
          user = new User(name: 'some name', plan: plan)
          user.save (err, member)->
            done(err)

      it 'can be test', (done)->
        user = new User(name: 'some name', plan: 'test')
        user.save (err, member)->
          done(err)

      it 'can be starter', (done)->
        user = new User(name: 'some name', plan: 'starter')
        user.save (err, member)->
          done(err)

      it 'cannot be anything else', (done)->
        user = new User(name: 'some name', plan: 'something else')
        user.save (err, member)->
          expect(err).not.to.be.null
          done()

      it 'cannot be null', (done)->
        user = new User(name: 'some name')
        user.save (err, member)->
          expect(err).not.to.be.null
          done()

    describe 'email', ->
      it 'requires unique emails', (done)->
        u = new User(email: 'my email', plan: 'solo')
        u.save (err, user)->
          expect(err).to.be.null
          expect(user.email).to.equal('my email')
          user2 = new User(email: 'my email', plan: 'solo')
          user2.save (err, user)->
            expect(err.name).to.equal('MongoError')
            expect(err.err).to.include('duplicate key error index: cineio-test.users.$email')
            done()


  describe 'streamLimit', ->
    testPlan = (planName, limit)->
      u = new User(plan: planName)
      expect(u.streamLimit()).to.equal(limit)

    it 'is 1 for free and starter', ->
      testPlan('free', 1)
      testPlan('starter', 1)

    it 'is 5 for solo', ->
      testPlan('solo', 5)

    it 'is Infinite for startup, enterprise, test', ->
      testPlan('startup', Infinity)
      testPlan('enterprise', Infinity)
      testPlan('test', Infinity)

  describe 'password generation', ->
    it 'generates a password and salt', (done)->
      u = new User(name: 'the name', email: 'the email', plan: 'free')
      expect(u.hashed_password).to.be.undefined
      expect(u.password_salt).to.be.undefined
      u.assignHashedPasswordAndSalt 'the password', (err)->
        expect(u.hashed_password).not.to.be.null
        expect(u.password_salt).not.to.be.null
        done(err)

    it 'can match the password from the user', (done)->
      u = new User(name: 'the name', email: 'the email', plan: 'free')
      u.assignHashedPasswordAndSalt 'the password', (err)->
        u.isCorrectPassword 'the password',  done

    it "errors when they don't match", (done)->
      u = new User(name: 'the name', email: 'the email', plan: 'free')
      u.assignHashedPasswordAndSalt 'the password', (err)->
        u.isCorrectPassword 'not the password',  (err)->
          expect(err).to.equal('Incorrect password')
          done()

  describe 'simpleCurrentUserJSON', ->
    it 'is has these keys', (done)->
      u = new User(name: 'my name', email: 'my email', hashed_password: 'hash', password_salt: 'salt', plan: 'free', githubId: 123)
      u.save (err, user)->
        expect(err).to.be.null
        keys = ['createdAt', 'email', 'firstName', 'githubId', 'id', 'lastName', 'masterKey', 'name', 'permissions', 'plan']
        jsonKeys = _.keys(u.simpleCurrentUserJSON()).sort()
        expect(jsonKeys).to.deep.equal(keys)
        done()

    it 'has a firstName', ->
      u = new User(name: 'my name')
      expect(u.simpleCurrentUserJSON().firstName).to.equal("my")

    it 'has an id', ->
      u = new User(name: 'my name')
      expect(u.simpleCurrentUserJSON().id.toString()).to.equal(u._id.toString())

    it 'has a lastName', ->
      u = new User(name: 'my name')
      expect(u.simpleCurrentUserJSON().lastName).to.equal("name")

  describe 'names', ->
    it 'has a firstName', ->
      u = new User(name: 'my full name')
      expect(u.firstName()).to.equal("my")

    it 'has a lastName', ->
      u = new User(name: 'my full name')
      expect(u.lastName()).to.equal("full name")

  describe '#projects and #permissionIdsFor', ->
    beforeEach (done)->
      @ownedProject1 = new Project(name: "in test project")
      @ownedProject1.save done
    beforeEach (done)->
      @ownedProject2 = new Project(name: "in test project2")
      @ownedProject2.save done
    beforeEach (done)->
      @notOwnedProject = new Project(name: "in test project3")
      @notOwnedProject.save done
    beforeEach (done)->
      @user = new User(plan: 'test')
      @user.permissions.push objectId: @ownedProject1._id, objectName: 'Project'
      @user.permissions.push objectId: @ownedProject2._id, objectName: 'Project'
      @user.save done

    describe '#permissionIdsFor', ->
      stringIds = (ary)->
        _.chain(ary).pluck('_id').invoke('toString').value().sort()

      it "returns the ids users's Projects", ->
        expectedProjectIds = stringIds([@ownedProject1, @ownedProject2])
        projectIds = _.invoke(@user.permissionIdsFor('Project'), 'toString').sort()
        expect(projectIds).to.deep.equal(expectedProjectIds)

      it 'returns the users projects', (done)->
        expectedProjectIds = stringIds([@ownedProject1, @ownedProject2])
        @user.projects (err, projects)->
          projectIds = stringIds(projects)
          expect(err).to.be.null
          expect(projectIds).to.deep.equal(expectedProjectIds)
          done()
