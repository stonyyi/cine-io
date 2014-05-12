Organization = Cine.model('organization')
Create = testApi Cine.api('organizations/create')
User = Cine.model('user')

describe 'Organizations#Create', ->

  beforeEach (done)->
    @user = new User(name: 'my name', email: 'my email')
    @user.save done

  it 'requires the user be logged in', (done)->
    Create (err, response, options)->
      expect(err).to.equal('not logged in')
      expect(response).to.be.null
      expect(options.status).to.equal(401)
      done()

  it 'creates an organization', (done)->
    params = name: 'new org'
    Create params, user: @user, (err, response, options)->
      expect(err).to.be.null
      expect(response.name).to.equal('new org')
      expect(response.apiKey).to.have.length(48)
      done()
