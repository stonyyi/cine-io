Project = Cine.model('project')
Create = testApi Cine.api('projects/create')
User = Cine.model('user')

describe 'Projects#Create', ->

  it 'requires the user be logged in', (done)->
    Create (err, response, options)->
      expect(err).to.equal('not logged in')
      expect(response).to.be.null
      expect(options.status).to.equal(401)
      done()

  describe 'success', ->
    beforeEach (done)->
      @user = new User(name: 'my name', email: 'my email')
      @user.save done

    it 'creates an project', (done)->
      params = name: 'new project'
      Create params, user: @user, (err, response, options)->
        expect(err).to.be.null
        expect(response.name).to.equal('new project')
        expect(response.apiKey).to.have.length(48)
        done()
    it 'adds the permission to the user', (done)->
      params = name: 'new project'
      expect(@user.permissions).to.have.length(0)
      Create params, user: @user, (err, response, options)=>
        User.findById @user._id, (err, user)->
          expect(err).to.be.null
          expect(user.permissions).to.have.length(1)
          expect(user.permissions[0].objectName).to.equal("Project")
          expect(user.permissions[0].objectId.toString()).to.equal(response._id.toString())
          done()
