ensureSiteAdmin = Cine.server_lib('ensure_site_admin_for_api')
User = Cine.server_model('user')

describe 'ensureSiteAdmin', ->
  beforeEach (done)->
    @user = new User
    @user.save done

  it 'returns false if not logged in', (done)->
    ensureSiteAdmin {}, (isSiteAdmin)->
      expect(isSiteAdmin).to.be.false
      done()

  it 'returns false if not a real user', (done)->
    ensureSiteAdmin sessionUserId: (new User)._id, (isSiteAdmin)->
      expect(isSiteAdmin).to.be.false
      done()

  it 'returns false if not an admin', (done)->
    ensureSiteAdmin sessionUserId: @user._id, (isSiteAdmin)->
      expect(isSiteAdmin).to.be.false
      done()

  it 'returns true if a site admin', (done)->
    @user.isSiteAdmin = true
    @user.save (err, user)->
      expect(err).to.be.null
      ensureSiteAdmin sessionUserId: user._id, (isSiteAdmin)->
        expect(isSiteAdmin).to.be.true
        done()

  describe '.unauthorizedCallback', ->
    it 'returns the proper unauthorized callback', (done)->
      ensureSiteAdmin.unauthorizedCallback (err, response, options)->
        expect(err).to.equal("Unauthorized")
        expect(response).to.be.null
        expect(options).to.deep.equal(status: 401)
        done()
