Account = Cine.server_model("account")
EdgecastStream = Cine.server_model("edgecast_stream")
User = Cine.server_model("user")
Project = Cine.server_model("project")
_ = require('underscore')
addNextStreamToProject = Cine.server_lib('add_next_stream_to_project')
createNewAccount = Cine.server_lib('create_new_account')
stubEdgecast = Cine.require 'test/helpers/stub_edgecast'
TurnUser = Cine.server_model('turn_user')

describe 'createNewAccount', ->

  beforeEach ->
    @accountAttributes = name: "the new account name", herokuId: 'heroku-id-yo', billingProvider: 'heroku', productPlans: {broadcast: 'starter'}
    @userAttributes = email: "my-email", name: 'user name', appdirectUUID: 'some appdirect uuid'
    @projectAttributes = name: 'this project'
    @streamAttributes = name: 'this stream'

  describe 'with peer', ->

    beforeEach (done)->
      @accountAttributes.productPlans = {broadcast: 'solo'}
      createNewAccount @accountAttributes, @userAttributes, @projectAttributes, @streamAttributes, (err, results)=>
        @results = results
        done(err)

    it 'adds the plan', ->
      # doing a deep equal of a mongo array vs js array doesn't work
      expect(@results.account.productPlans.peer).to.have.length(0)
      expect(@results.account.productPlans.broadcast).to.have.length(1)
      expect(@results.account.productPlans.broadcast[0]).to.equal('solo')

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
        expect(account.billingEmail).to.equal("my-email")
        done()

    it 'links the provider', ->
      expect(@results.account.billingProvider).to.equal('heroku')

    it 'adds the plan', ->
      # doing a deep equal of a mongo array vs js array doesn't work
      expect(@results.account.productPlans.peer).to.have.length(0)
      expect(@results.account.productPlans.broadcast).to.have.length(1)
      expect(@results.account.productPlans.broadcast[0]).to.equal('starter')

    it 'creates a user', (done)->
      expect(@results.user.name).to.equal("user name")
      User.findById @results.user._id, (err, user)->
        expect(err).to.be.null
        expect(user.name).to.equal("user name")
        expect(user.email).to.equal("my-email")
        expect(user.appdirectUUID).to.equal("some appdirect uuid")
        done()

    it 'creates a turn user', (done)->
      TurnUser.findOne _project: @results.project._id, (err, tu)=>
        expect(err).to.be.null
        expect(tu.name).to.equal(@results.project.publicKey)
        expect(tu.realm).to.equal('cine.io')
        expect(tu.hmackey).to.be.ok
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

  describe 'with a stream', ->
    beforeEach (done)->
      @stream = new EdgecastStream(instanceName: 'cines', streamName: 'some-name')
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

  describe 'without an email', ->
    beforeEach ->
      delete @userAttributes.email

    beforeEach (done)->
      createNewAccount @accountAttributes, @userAttributes, @projectAttributes, @streamAttributes, (err, results)=>
        @results = results
        done(err)

    it 'does not create a user without an email', ->
      expect(@results.user).to.be.undefined

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

    beforeEach ->
      @userAttributes.email = '  my-email  '

    beforeEach (done)->
      @user = new User(email: "my-email", name: 'user name')
      @user.save done

    beforeEach (done)->
      createNewAccount @accountAttributes, @userAttributes, @projectAttributes, @streamAttributes, (err, results)=>
        @results = results
        done(err)

    it 'adds the appdirectUUID to the user', (done)->
      User.findById @results.user._id, (err, user)->
        expect(err).to.be.null
        expect(user.appdirectUUID).to.equal('some appdirect uuid')
        done()

    it 'adds the new account to the same user', (done)->
      User.findById @results.user._id, (err, user)=>
        expect(err).to.be.null
        expect(user._accounts).to.have.length(1)
        expect(user._accounts[0].toString()).to.equal(@results.account._id.toString())
        done()

    it 'does not create a new user', (done)->
      User.count (err, count)->
        expect(err).to.be.null
        expect(count).to.equal(1)
        done()
