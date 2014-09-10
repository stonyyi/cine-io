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
        expect(@mailerSpies[0].firstCall.args[1]).to.equal("heroku")
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
      findOrCreateResourcesFromHerokuAndEngineYard.newEngineYardAccount 'new-engineyard-user@engineyard.com', 'pro', (err, @user, @project)=>
        expect(@mailerSpies[0].firstCall.args[0].name).to.equal("new-engineyard-user")
        expect(@mailerSpies[0].firstCall.args[1]).to.equal("engineyard")
        done(err)

    describe "without a new stream", ->
      beforeEach (done)->
        findOrCreateResourcesFromHerokuAndEngineYard.newEngineYardAccount 'new-engineyard-user@engineyard.com', 'pro', (err, @account, @project)=>
          done(err)

      it 'does not create a new user', (done)->
        User.findOne _accounts: {$in: [@account._id]}, (err, user)->
          expect(err).to.be.null
          expect(user).to.be.null
          done()

      it 'creates a new account', ->
        expect(@account.name).to.equal("new-engineyard-user")
        expect(@account.engineyardId).to.equal("new-engineyard-user@engineyard.com")

      it 'creates a new project', ->
        expect(@project).to.be.instanceOf(Project)
        expect(@project.name).to.equal("new-engineyard-user")
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
        findOrCreateResourcesFromHerokuAndEngineYard.newEngineYardAccount 'new-engineyard-user@engineyard.com', 'pro', (err, @user, @project)=>
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
      @account = new Account(plans: ['test'], name: 'the account name')
      @account.save done

    beforeEach (done)->
      @accountUser = new User(email: 'some email')
      @accountUser._accounts.push @account._id
      @accountUser.save done

    beforeEach (done)->
      @secondUser = new User(email: 'second email')
      @secondUser.save done


    it 'returns a user who is already part of the account', (done)->
      findOrCreateResourcesFromHerokuAndEngineYard.findUser @account._id, 'some email', (err, user)=>
        expect(err).to.be.null
        expect(user._id.toString()).to.equal(@accountUser._id.toString())
        done()

    it 'adds a user to an account', (done)->
      findOrCreateResourcesFromHerokuAndEngineYard.findUser @account._id, 'second email', (err, user)=>
        expect(err).to.be.null
        expect(user._id.toString()).to.equal(@secondUser._id.toString())
        done()

    it 'creates a new user and adds them to the account', (done)->
      findOrCreateResourcesFromHerokuAndEngineYard.findUser @account._id, 'other email', (err, user)=>
        expect(err).to.be.null
        expect(user._id.toString()).not.to.equal(@accountUser._id.toString())
        expect(user._id.toString()).not.to.equal(@secondUser._id.toString())
        expect(user.email).to.equal('other email')
        expect(user.name).to.equal('the account name')
        done()

  describe 'updatePlan', ->

    beforeEach (done)->
      @account = new Account(plans: ['test'])
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

  describe 'deleteAccount', ->

    beforeEach (done)->
      @account = new Account(plans: ['test'])
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
