getUser = Cine.server_lib('get_user')
User = Cine.server_model('user')
_ = require('underscore')

describe 'getUser', ->

  beforeEach (done)->
    @user = new User
    @user.save done

  it 'requires a sessionUserId or a masterKey', (done)->
    getUser {}, (err, user, options)->
      expect(err).to.equal('not logged in or masterKey not supplied')
      expect(user).to.be.null
      expect(options).to.deep.equal(status: 401)
      done()

  it 'can take a sessionUserId', (done)->
    getUser sessionUserId: @user._id, (err, user, options)=>
      expect(err).to.be.null
      expect(options).to.be.undefined
      expect(user._id.toString()).to.equal(@user._id.toString())
      done()

  it 'can take a master token', (done)->
    getUser masterKey: @user.masterKey, (err, user, options)=>
      expect(err).to.be.null
      expect(options).to.be.undefined
      expect(user._id.toString()).to.equal(@user._id.toString())
      done()


  it 'returns 404 when not found', (done)->
    getUser sessionUserId: (new User)._id, (err, user, options)->
      expect(err).to.equal('user not found')
      expect(user).to.be.null
      expect(options).to.deep.equal(status: 404)
      done()
