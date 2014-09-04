_ = require('underscore')
User = Cine.server_model('user')
modelTimestamps = Cine.require('test/helpers/model_timestamps')
BackboneUser = Cine.model('user')
Project = Cine.server_model('project')

describe 'User', ->
  modelTimestamps(User, email: 'hey', name: 'yo')

  describe 'validations', ->
    describe 'email', ->
      it 'requires unique emails', (done)->
        u = new User(email: 'my email')
        u.save (err, user)->
          expect(err).to.be.null
          expect(user.email).to.equal('my email')
          user2 = new User(email: 'my email')
          user2.save (err, user)->
            expect(err.name).to.equal('MongoError')
            expect(err.err).to.include('duplicate key error index: cineio-test.users.$email')
            done()

  describe 'password generation', ->
    it 'generates a password and salt', (done)->
      u = new User(name: 'the name', email: 'the email')
      expect(u.hashed_password).to.be.undefined
      expect(u.password_salt).to.be.undefined
      u.assignHashedPasswordAndSalt 'the password', (err)->
        expect(u.hashed_password).not.to.be.null
        expect(u.password_salt).not.to.be.null
        done(err)

    it 'can match the password from the user', (done)->
      u = new User(name: 'the name', email: 'the email')
      u.assignHashedPasswordAndSalt 'the password', (err)->
        u.isCorrectPassword 'the password',  done

    it "errors when they don't match", (done)->
      u = new User(name: 'the name', email: 'the email')
      u.assignHashedPasswordAndSalt 'the password', (err)->
        u.isCorrectPassword 'not the password',  (err)->
          expect(err).to.equal('Incorrect password')
          done()

  describe 'simpleCurrentUserJSON', ->
    it 'is has these keys', (done)->
      u = new User(name: 'my name', email: 'my email', hashed_password: 'hash', password_salt: 'salt', githubId: 123, appdirectUUID: 'abc')
      u.save (err, user)->
        expect(err).to.be.null
        keys = ['_accounts', 'appdirectUUID', 'createdAt', 'email', 'firstName', 'githubId', 'id', 'isSiteAdmin', 'lastName', 'masterKey', 'name']
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
