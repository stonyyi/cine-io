Project = Cine.server_model('project')
Account = Cine.server_model('account')
User = Cine.server_model('user')
BillingProvider = Cine.server_model('billing_provider')
findOrCreateResourcesFromHeroku = Cine.server_lib('find_or_create_resources_from_heroku')
EdgecastStream = Cine.server_model('edgecast_stream')
stubEdgecast = Cine.require 'test/helpers/stub_edgecast'
assertEmailSent = Cine.require 'test/helpers/assert_email_sent'
requiresSeed = Cine.require 'test/helpers/requires_seed'

describe 'findOrCreateResourcesFromHeroku', ->

  describe 'newAccount' , ->

    requiresSeed()

    assertEmailSent.admin "newUser"

    it 'sends a welcome email', (done)->
      findOrCreateResourcesFromHeroku.newAccount 'new-heroku-user@heroku.com', 'enterprise', (err, @user, @project)=>
        expect(@mailerSpies[0].firstCall.args[0].name).to.equal("new-heroku-user")
        expect(@mailerSpies[0].firstCall.args[1]).to.equal("heroku")
        done(err)

    describe "without a new stream", ->
      beforeEach (done)->
        findOrCreateResourcesFromHeroku.newAccount 'new-heroku-user@heroku.com', 'enterprise', (err, @account, @project)=>
          done(err)

      # TODO DEPRECATED, no need to create user
      it 'creates a new user', (done)->
        User.findOne _accounts: {$in: [@account._id]}, (err, user)->
          console.log("FIND user")
          expect(err).to.be.null
          expect(user.email).be.undefined
          expect(user.name).to.equal("new-heroku-user")
          done()

      it 'creates a new account', ->
        expect(@account.name).to.equal("new-heroku-user")
        expect(@account.herokuId).to.equal("new-heroku-user@heroku.com")

      it 'creates a new project', ->
        expect(@project).to.be.instanceOf(Project)
        expect(@project.name).to.equal("new-heroku-user")
        expect(@project.streamsCount).to.equal(0)
        expect(@project._account.toString()).to.equal(@account._id.toString())

      it 'adds the correct billingProvider', (done)->
        BillingProvider.findById @account._billingProvider, (err, provider)->
          expect(err).to.be.null
          expect(provider.name).to.equal('heroku')
          done()

    describe 'with a new stream', ->
      stubEdgecast()

      beforeEach (done)->
        @stream = new EdgecastStream(streamName: 'name1')
        @stream.save(done)
      beforeEach (done)->
        findOrCreateResourcesFromHeroku.newAccount 'new-heroku-user@heroku.com', 'enterprise', (err, @user, @project)=>
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
      @account = new Account(tempPlan: 'test', name: 'the account name')
      @account.save done

    beforeEach (done)->
      @accountUser = new User(email: 'some email')
      @accountUser._accounts.push @account._id
      @accountUser.save done

    beforeEach (done)->
      @secondUser = new User(email: 'second email')
      @secondUser.save done


    it 'returns a user who is already part of the account', (done)->
      findOrCreateResourcesFromHeroku.findUser @account._id, 'some email', (err, user)=>
        expect(err).to.be.null
        expect(user._id.toString()).to.equal(@accountUser._id.toString())
        done()

    it 'adds a user to an account', (done)->
      findOrCreateResourcesFromHeroku.findUser @account._id, 'second email', (err, user)=>
        expect(err).to.be.null
        expect(user._id.toString()).to.equal(@secondUser._id.toString())
        done()

    it 'creates a new user and adds them to the account', (done)->
      findOrCreateResourcesFromHeroku.findUser @account._id, 'other email', (err, user)=>
        expect(err).to.be.null
        expect(user._id.toString()).not.to.equal(@accountUser._id.toString())
        expect(user._id.toString()).not.to.equal(@secondUser._id.toString())
        expect(user.email).to.equal('other email')
        expect(user.name).to.equal('the account name')
        done()

  describe 'updatePlan', ->

    beforeEach (done)->
      @account = new Account(tempPlan: 'test')
      @account.save done

    it "updates the account's plan", (done)->
      findOrCreateResourcesFromHeroku.updatePlan @account._id, "startup", (err, account)=>
        expect(err).to.be.null
        expect(account._id.toString()).to.equal(@account._id.toString())
        expect(account.tempPlan).to.equal("startup")
        Account.findById @account._id, (err, accountFromDb)->
          expect(err).to.be.null
          expect(accountFromDb.tempPlan).to.equal('startup')
          done()

    it "undeletes an account", (done)->
      @account.deletedAt = new Date
      @account.save (err, account)=>
        expect(err).to.be.null
        expect(account.deletedAt).to.be.instanceOf(Date)
        findOrCreateResourcesFromHeroku.updatePlan @account._id, "startup", (err, account)=>
          expect(err).to.be.null
          expect(account._id.toString()).to.equal(@account._id.toString())
          expect(account.deletedAt).to.be.undefined
          done()

  describe 'deleteAccount', ->

    beforeEach (done)->
      @account = new Account(tempPlan: 'test')
      @account.save done

    it "adds deletedAt to an account", (done)->
      expect(@account.deletedAt).to.be.undefined
      findOrCreateResourcesFromHeroku.deleteAccount @account._id, (err, account)=>
        expect(err).to.be.undefined
        expect(account._id.toString()).to.equal(@account._id.toString())
        expect(account.deletedAt).to.be.instanceOf(Date)
        Account.findById @account._id, (err, accountFromDb)->
          expect(err).to.be.null
          expect(accountFromDb.deletedAt).to.be.instanceOf(Date)
          done()
