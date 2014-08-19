Account = Cine.server_model("account")
EdgecastStream = Cine.server_model("edgecast_stream")
User = Cine.server_model("user")
Project = Cine.server_model("project")
BillingProvider = Cine.server_model('billing_provider')
_ = require('underscore')
addNextStreamToProject = Cine.server_lib('add_next_stream_to_project')
createNewAccount = Cine.server_lib('create_new_account')
stubEdgecast = Cine.require 'test/helpers/stub_edgecast'
requiresSeed = Cine.require 'test/helpers/requires_seed'

describe 'createNewAccount', ->

  requiresSeed()

  beforeEach ->
    @accountAttributes = name: "the new account name", plan: 'starter', herokuId: 'heroku-id-yo', billingProviderName: 'heroku'
    @userAttributes = email: "my-email", name: 'user name'
    @projectAttributes = name: 'this project'
    @streamAttributes = name: 'this stream'

  describe 'without a stream', ->
    beforeEach (done)->
      createNewAccount @accountAttributes, @userAttributes, @projectAttributes, @streamAttributes, (err, results)=>
        @results = results
        done(err)

    it 'creates a new acccount', (done)->
      expect(@results.account.name).to.equal("the new account name")
      Account.findById @results.account._id, (err, account)->
        expect(err).to.be.null
        expect(account.name).to.equal("the new account name")
        done()

    it 'links the provider', (done)->
      BillingProvider.findById @results.account._billingProvider, (err, provider)->
        expect(err).to.be.null
        expect(provider.name).to.equal('heroku')
        done()

    it 'creates a user', (done)->
      expect(@results.user.name).to.equal("user name")
      User.findById @results.user._id, (err, user)->
        expect(err).to.be.null
        expect(user.name).to.equal("user name")
        expect(user.email).to.equal("my-email")
        done()

    # TODO: DEPRECATED
    it 'adds a plan to the user', (done)->
      User.findById @results.user._id, (err, user)->
        expect(err).to.be.null
        expect(user.plan).to.equal('starter')
        done()

    # TODO: DEPRECATED
    it 'adds a tempPlan to the account', (done)->
      Account.findById @results.account._id, (err, account)->
        expect(err).to.be.null
        expect(account.tempPlan).to.equal('starter')
        done()

    # TODO: DEPRECATED
    it 'creates a project linked to the user', (done)->
      User.findById @results.user._id, (err, user)=>
        expect(err).to.be.null
        expect(user.permissions).to.have.length(1)
        expect(user.permissions[0].objectId.toString()).to.equal(@results.project._id.toString())
        expect(user.permissions[0].objectName).to.equal("Project")
        done()

    # TODO: DEPRECATED
    it 'creates a masterKey that is the same as the user', ->
      expect(@results.account.masterKey).to.have.length(64)
      expect(@results.user.masterKey).to.have.length(64)
      expect(@results.account.masterKey).to.equal(@results.user.masterKey)

    # TODO: DEPRECATED
    it "adds a herokuId to the account when it's from heroku", (done)->
      User.findById @results.user._id, (err, user)->
        expect(err).to.be.null
        expect(user.herokuId).to.equal('heroku-id-yo')
        done()

    it "adds a herokuId to the account", (done)->
      Account.findById @results.account._id, (err, account)->
        expect(err).to.be.null
        expect(account.herokuId).to.equal('heroku-id-yo')
        done()

    it 'creates a project linked to the account', (done)->
      expect(@results.project.name).to.equal("this project")
      Project.findById @results.project._id, (err, project)=>
        expect(err).to.be.null
        expect(project.name).to.equal("this project")
        expect(project._account.toString()).to.equal(@results.account._id.toString())
        done()

    it 'does not create a stream associated with the project', (done)->
      EdgecastStream.findOne _project: @results.project._id, (err, stream)->
        expect(err).to.be.null
        expect(stream).to.be.null
        done()

    it 'adds a plan to the account'
    it 'adds a billing source to the account'

  describe 'with a stream', ->
    beforeEach (done)->
      @stream = new EdgecastStream(instanceName: 'cines')
      @stream.save done

    stubEdgecast()

    beforeEach (done)->
      createNewAccount @accountAttributes, @userAttributes, @projectAttributes, @streamAttributes, (err, results)=>
        @results = results
        done(err)

    it 'creates a stream associated with the project', (done)->
      EdgecastStream.findOne _project: @results.project._id, (err, stream)=>
        expect(err).to.be.null
        expect(stream._id.toString()).to.equal(@stream._id.toString())
        done()

  describe 'with a password', ->
    beforeEach ->
      @userAttributes.cleartextPassword = 'my password'

    beforeEach (done)->
      createNewAccount @accountAttributes, @userAttributes, @projectAttributes, @streamAttributes, (err, results)=>
        @results = results
        done(err)

    it 'adds a hashed password to the user', (done)->
      expect(@results.user.hashed_password).to.be.ok
      expect(@results.user.password_salt).to.be.ok
      User.findById @results.user._id, (err, user)->
        expect(err).to.be.null
        expect(user.hashed_password).to.be.ok
        expect(user.password_salt).to.be.ok
        done()

    it 'makes the correct password', (done)->
      @results.user.isCorrectPassword 'my password', (err)=>
        expect(err).to.be.null
        User.findById @results._user
        done()

  describe 'with an existing user', ->

    beforeEach (done)->
      @user = new User(email: "my-email", name: 'user name', plan: 'enterprise')
      @user.save done

    beforeEach (done)->
      createNewAccount @accountAttributes, @userAttributes, @projectAttributes, @streamAttributes, (err, results)=>
        @results = results
        done(err)

    it 'adds the new account to the same user'

    # TODO: DEPRECATED
    it 'updates the plan of the existing user', (done)->
      expect(@results.user.plan).to.equal('starter')
      User.findById @results.user._id, (err, user)->
        expect(err).to.be.null
        expect(user.plan).to.equal('starter')
        done()
