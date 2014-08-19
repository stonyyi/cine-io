Account = Cine.server_model('account')
_ = require('underscore')
modelTimestamps = Cine.require('test/helpers/model_timestamps')
Project = Cine.server_model('project')

describe 'Account', ->
  modelTimestamps(Account, name: 'hey')

  describe 'masterKey', ->
    it 'has a unique masterKey generated on save', (done)->
      account = new Account(name: 'some name')
      account.save (err)->
        expect(err).to.be.null
        expect(account.masterKey.length).to.equal(64)
        done()

    it 'will not override the masterKey on future saves', (done)->
      account = new Account(name: 'some name')
      account.save (err)->
        expect(err).to.be.null
        masterKey = account.masterKey
        expect(masterKey.length).to.equal(64)
        account.save (err)->
          expect(account.masterKey).to.equal(masterKey)
          done(err)

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
