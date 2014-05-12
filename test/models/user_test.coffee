_ = require('underscore')
User = Cine.model('user')
modelTimestamps = Cine.require('test/helpers/model_timestamps')

describe 'User', ->
  modelTimestamps(User, email: 'hey', name: 'yo')

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
    it 'is has these keys', ->
      u = new User(name: 'my name', email: 'my email', hashed_password: 'hash', password_salt: 'salt')
      keys = ['_id', 'createdAt', 'email', 'firstName', 'lastName', 'name', 'permissions']
      jsonKeys = _.keys(u.simpleCurrentUserJSON()).sort()
      expect(jsonKeys).to.deep.equal(keys)

    it 'has a firstName', ->
      u = new User(name: 'my name')
      expect(u.simpleCurrentUserJSON().firstName).to.equal("my")

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

  describe 'toInternalApiJSON', ->
    it 'only includes the does not include the hashed_password nor password_salt', (done)->
      ref = new User
      u = new User(name: 'my name', _referringUser: ref._id, hashed_password: 'hash', password_salt: 'salt', email: 'hello')
      u.save (err)->
        expect(err).to.be.null
        jsonKeys = _.keys(u.toInternalApiJSON()).sort()
        expect(jsonKeys).to.deep.equal(['_id', '_referringUser', 'createdAt', 'email', 'generation', 'name', 'permissions', 'updatedAt'])
        done()
