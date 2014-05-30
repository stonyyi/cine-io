_ = require('underscore')
User = Cine.server_model('user')
modelTimestamps = Cine.require('test/helpers/model_timestamps')
BackboneUser = Cine.model('user')

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
    it 'is has these keys', ->
      u = new User(name: 'my name', email: 'my email', hashed_password: 'hash', password_salt: 'salt', plan: 'free')
      keys = ['createdAt', 'email', 'firstName', 'id', 'lastName', 'name', 'permissions', 'plan']
      jsonKeys = _.keys(u.simpleCurrentUserJSON()).sort()
      expect(jsonKeys).to.deep.equal(keys)

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
