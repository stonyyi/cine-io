Account = Cine.server_model('account')
_ = require('underscore')
modelTimestamps = Cine.require('test/helpers/model_timestamps')
Project = Cine.server_model('project')
BackboneUser = Cine.model('user')

describe 'Account', ->
  modelTimestamps(Account, tempPlan: 'enterprise')

  describe 'validations', ->
    describe 'plan', ->
      _.each BackboneUser.plans, (plan)->
        it "can be #{plan}", (done)->
          user = new Account(name: 'some name', tempPlan: plan)
          user.save (err, member)->
            done(err)

      it 'can be test', (done)->
        user = new Account(name: 'some name', tempPlan: 'test')
        user.save (err, member)->
          done(err)

      it 'can be starter', (done)->
        user = new Account(name: 'some name', tempPlan: 'starter')
        user.save (err, member)->
          done(err)

      it 'cannot be anything else', (done)->
        user = new Account(name: 'some name', tempPlan: 'something else')
        user.save (err, member)->
          expect(err).not.to.be.null
          done()

      it 'cannot be null', (done)->
        user = new Account(name: 'some name')
        user.save (err, member)->
          expect(err).not.to.be.null
          done()

  describe 'masterKey', ->
    it 'has a unique masterKey generated on save', (done)->
      account = new Account(name: 'some name', tempPlan: 'test')
      account.save (err)->
        expect(err).to.be.null
        expect(account.masterKey.length).to.equal(64)
        done()

    it 'will not override the masterKey on future saves', (done)->
      account = new Account(name: 'some name', tempPlan: 'test')
      account.save (err)->
        expect(err).to.be.null
        masterKey = account.masterKey
        expect(masterKey.length).to.equal(64)
        account.save (err)->
          expect(account.masterKey).to.equal(masterKey)
          done(err)

  describe 'streamLimit', ->
    testPlan = (planName, limit)->
      account = new Account(tempPlan: planName)
      expect(account.streamLimit()).to.equal(limit)

    it 'is 1 for free and starter', ->
      testPlan('free', 1)
      testPlan('starter', 1)

    it 'is 5 for solo', ->
      testPlan('solo', 5)

    it 'is Infinite for startup, enterprise, test', ->
      testPlan('startup', Infinity)
      testPlan('enterprise', Infinity)
      testPlan('test', Infinity)

  describe '#projects', ->

    beforeEach (done)->
      @account = new Account(tempPlan: 'test')
      @account.save done

    beforeEach (done)->
      @ownedProject1 = new Project(name: "in test project", _account: @account._id)
      @ownedProject1.save done
    beforeEach (done)->
      @ownedProject2 = new Project(name: "in test project2", _account: @account._id)
      @ownedProject2.save done
    beforeEach (done)->
      @notOwnedProject = new Project(name: "in test project3")
      @notOwnedProject.save done

    it 'returns the projects', (done)->
      @account.projects (err, projects)=>
        expect(err).to.be.null
        expect(projects).to.have.length(2)
        expect(projects[0]._id.toString()).to.equal(@ownedProject1._id.toString())
        expect(projects[1]._id.toString()).to.equal(@ownedProject2._id.toString())
        done()
