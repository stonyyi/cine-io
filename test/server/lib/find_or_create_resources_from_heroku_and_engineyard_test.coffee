Project = Cine.server_model('project')
Account = Cine.server_model('account')
User = Cine.server_model('user')
findOrCreateResourcesFromHerokuAndEngineYard = Cine.server_lib('find_or_create_resources_from_heroku_and_engineyard')
EdgecastStream = Cine.server_model('edgecast_stream')
stubEdgecast = Cine.require 'test/helpers/stub_edgecast'
assertEmailSent = Cine.require 'test/helpers/assert_email_sent'

describe 'findOrCreateResourcesFromHerokuAndEngineYard', ->

  describe 'newHerokuAccount' , ->

    assertEmailSent.admin "newUser"

    it 'sends a welcome email', (done)->
      findOrCreateResourcesFromHerokuAndEngineYard.newHerokuAccount 'new-heroku-user@heroku.com', 'pro', (err, @user, @project)=>
        expect(@mailerSpies[0].firstCall.args[0].name).to.equal("new-heroku-user")
        expect(@mailerSpies[0].firstCall.args[2]).to.equal("heroku")
        done(err)

    describe "without a new stream", ->
      beforeEach (done)->
        findOrCreateResourcesFromHerokuAndEngineYard.newHerokuAccount 'new-heroku-user@heroku.com', 'pro', (err, @account, @project)=>
          done(err)

      it 'does not create a new user', (done)->
        User.findOne _accounts: {$in: [@account._id]}, (err, user)->
          expect(err).to.be.null
          expect(user).to.be.null
          done()

      it 'creates a new account', ->
        expect(@account.name).to.equal("new-heroku-user")
        expect(@account.herokuId).to.equal("new-heroku-user@heroku.com")

      it 'creates a new project', ->
        expect(@project).to.be.instanceOf(Project)
        expect(@project.name).to.equal("new-heroku-user")
        expect(@project.streamsCount).to.equal(0)
        expect(@project._account.toString()).to.equal(@account._id.toString())

      it 'adds the correct billingProvider', ->
        expect(@account.billingProvider).to.equal('heroku')

    describe 'with a new stream', ->
      stubEdgecast()

      beforeEach (done)->
        @stream = new EdgecastStream(streamName: 'name1')
        @stream.save(done)
      beforeEach (done)->
        findOrCreateResourcesFromHerokuAndEngineYard.newHerokuAccount 'new-heroku-user@heroku.com', 'pro', (err, @user, @project)=>
          done(err)

      it 'adds a stream to that project', (done)->
        expect(@project.streamsCount).to.equal(1)
        EdgecastStream.find _project: @project._id, (err, streams)=>
          expect(err).to.be.null
          expect(streams).to.have.length(1)
          expect(streams[0]._id.toString()).to.equal(@stream._id.toString())
          done()

  describe 'newEngineYardAccount' , ->

    assertEmailSent.admin "newUser"

    it 'sends a welcome email', (done)->
      findOrCreateResourcesFromHerokuAndEngineYard.newEngineYardAccount '9141-cine.io_cineiosinatraexampleapp_cineiosinatraexampleapp', 'pro', (err, @user, @project)=>
        expect(@mailerSpies[0].firstCall.args[0].name).to.equal("cine.io_cineiosinatraexampleapp_cineiosinatraexampleapp")
        expect(@mailerSpies[0].firstCall.args[2]).to.equal("engineyard")
        done(err)

    describe "without a new stream", ->
      beforeEach (done)->
        findOrCreateResourcesFromHerokuAndEngineYard.newEngineYardAccount '9141-cine.io_cineiosinatraexampleapp_cineiosinatraexampleapp', 'pro', (err, @account, @project)=>
          done(err)

      it 'does not create a new user', (done)->
        User.findOne _accounts: {$in: [@account._id]}, (err, user)->
          expect(err).to.be.null
          expect(user).to.be.null
          done()

      it 'creates a new account', ->
        expect(@account.name).to.equal("cine.io_cineiosinatraexampleapp_cineiosinatraexampleapp")
        expect(@account.engineyardId).to.equal("9141-cine.io_cineiosinatraexampleapp_cineiosinatraexampleapp")

      it 'creates a new project', ->
        expect(@project).to.be.instanceOf(Project)
        expect(@project.name).to.equal("cine.io_cineiosinatraexampleapp_cineiosinatraexampleapp")
        expect(@project.streamsCount).to.equal(0)
        expect(@project._account.toString()).to.equal(@account._id.toString())

      it 'adds the correct billingProvider', ->
        expect(@account.billingProvider).to.equal('engineyard')

    describe 'with a new stream', ->
      stubEdgecast()

      beforeEach (done)->
        @stream = new EdgecastStream(streamName: 'name1')
        @stream.save(done)
      beforeEach (done)->
        findOrCreateResourcesFromHerokuAndEngineYard.newEngineYardAccount '9141-cine.io_cineiosinatraexampleapp_cineiosinatraexampleapp', 'pro', (err, @user, @project)=>
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
      @account = new Account(billingProvider: 'heroku', plans: ['test'], name: 'the account name')
      @account.save done

    beforeEach (done)->
      @accountUser = new User(email: 'some email', createdAtIP: '888.777.666.555', lastLoginIP: '666.555.444.333')
      @accountUser._accounts.push @account._id
      @accountUser.save done

    beforeEach (done)->
      @secondUser = new User(email: 'second email', createdAtIP: '888.777.666.554', lastLoginIP: '666.555.444.332')
      @secondUser.save done

    beforeEach ->
      @req = ip: '111.222.333.444'

    it 'returns a user who is already part of the account', (done)->
      findOrCreateResourcesFromHerokuAndEngineYard.findUser @account._id, 'some email', @req, (err, user)=>
        expect(err).to.be.null
        expect(user._id.toString()).to.equal(@accountUser._id.toString())
        done()

    it 'sets lastLoginIP to a user who is already part of the account', (done)->
      findOrCreateResourcesFromHerokuAndEngineYard.findUser @account._id, 'some email', @req, (err, user)->
        expect(err).to.be.null
        expect(user.createdAtIP).to.equal('888.777.666.555')
        expect(user.lastLoginIP).to.equal('111.222.333.444')
        done()

    it 'adds a user to an account', (done)->
      findOrCreateResourcesFromHerokuAndEngineYard.findUser @account._id, 'second email', @req, (err, user)=>
        expect(err).to.be.null
        expect(user._id.toString()).to.equal(@secondUser._id.toString())
        done()

    it 'sets lastLoginIP to an existing user but newly added to an account', (done)->
      findOrCreateResourcesFromHerokuAndEngineYard.findUser @account._id, 'second email', @req, (err, user)->
        expect(err).to.be.null
        expect(user.createdAtIP).to.equal('888.777.666.554')
        expect(user.lastLoginIP).to.equal('111.222.333.444')
        done()

    it 'creates a new user and adds them to the account', (done)->
      findOrCreateResourcesFromHerokuAndEngineYard.findUser @account._id, 'other email', @req, (err, user)=>
        expect(err).to.be.null
        expect(user._id.toString()).not.to.equal(@accountUser._id.toString())
        expect(user._id.toString()).not.to.equal(@secondUser._id.toString())
        expect(user.email).to.equal('other email')
        expect(user.name).to.equal('the account name')
        done()

    it 'sets createdAtIP and lastLoginIP on new users', (done)->
      findOrCreateResourcesFromHerokuAndEngineYard.findUser @account._id, 'other email', @req, (err, user)->
        expect(err).to.be.null
        expect(user.createdAtIP).to.equal('111.222.333.444')
        expect(user.lastLoginIP).to.equal('111.222.333.444')
        done()

  describe 'updatePlan', ->

    beforeEach (done)->
      @account = new Account(billingProvider: 'heroku', plans: ['test'])
      @account.save done

    it "updates the account's plan", (done)->
      findOrCreateResourcesFromHerokuAndEngineYard.updatePlan @account._id, "basic", (err, account)=>
        expect(err).to.be.null
        expect(account._id.toString()).to.equal(@account._id.toString())
        expect(account.plans).have.length(1)
        expect(account.plans[0]).to.equal("basic")
        Account.findById @account._id, (err, accountFromDb)->
          expect(err).to.be.null
          expect(accountFromDb.plans).have.length(1)
          expect(accountFromDb.plans[0]).to.equal('basic')
          done()

    it "undeletes an account", (done)->
      @account.deletedAt = new Date
      @account.save (err, account)=>
        expect(err).to.be.null
        expect(account.deletedAt).to.be.instanceOf(Date)
        findOrCreateResourcesFromHerokuAndEngineYard.updatePlan @account._id, "basic", (err, account)=>
          expect(err).to.be.null
          expect(account._id.toString()).to.equal(@account._id.toString())
          expect(account.deletedAt).to.be.undefined
          done()

    it "unthrottles an account", (done)->
      @account.throttledAt = new Date
      @account.save (err, account)=>
        expect(err).to.be.null
        expect(account.throttledAt).to.be.instanceOf(Date)
        findOrCreateResourcesFromHerokuAndEngineYard.updatePlan @account._id, "basic", (err, account)=>
          expect(err).to.be.null
          expect(account._id.toString()).to.equal(@account._id.toString())
          expect(account.throttledAt).to.be.undefined
          done()

  describe 'deleteAccount', ->

    beforeEach (done)->
      @account = new Account(billingProvider: 'heroku', plans: ['test'])
      @account.save done

    it "adds deletedAt to an account", (done)->
      expect(@account.deletedAt).to.be.undefined
      findOrCreateResourcesFromHerokuAndEngineYard.deleteAccount @account._id, (err, account)=>
        expect(err).to.be.undefined
        expect(account._id.toString()).to.equal(@account._id.toString())
        expect(account.deletedAt).to.be.instanceOf(Date)
        Account.findById @account._id, (err, accountFromDb)->
          expect(err).to.be.null
          expect(accountFromDb.deletedAt).to.be.instanceOf(Date)
          done()
