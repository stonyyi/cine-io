Project = Cine.server_model('project')
Create = testApi Cine.api('projects/create')
User = Cine.server_model('user')
stubEdgecast = Cine.require 'test/helpers/stub_edgecast'
EdgecastStream = Cine.server_model('edgecast_stream')

describe 'Projects#Create', ->
  testApi.requresLoggedIn Create

  beforeEach (done)->
    @user = new User(name: 'my name', email: 'my email')
    @user.save done
  describe 'success', ->

    it 'creates an project', (done)->
      params = name: 'new project', plan: 'enterprise'
      Create params, user: @user, (err, response, options)->
        expect(err).to.be.null
        expect(response.name).to.equal('new project')
        expect(response.publicKey).to.have.length(32)
        expect(response.plan).to.equal('enterprise')
        done()

    it 'adds the permission to the user', (done)->
      params = name: 'new project', plan: 'enterprise'
      expect(@user.permissions).to.have.length(0)
      Create params, user: @user, (err, response, options)=>
        User.findById @user._id, (err, user)->
          expect(err).to.be.null
          expect(user.permissions).to.have.length(1)
          expect(user.permissions[0].objectName).to.equal("Project")
          expect(user.permissions[0].objectId.toString()).to.equal(response.id)
          done()

  describe 'with adding as stream', ->
    beforeEach (done)->
      @stream = new EdgecastStream(instanceName: 'cines', streamName: 'cine1', streamKey: 'bass35', eventName: 'cine1ENAME')
      @stream.save done

    stubEdgecast()

    it 'adds a stream to the new project', (done)->
      params = name: 'new project', plan: 'enterprise', createStream: 'true'
      Create params, user: @user, (err, response, options)->
        expect(err).to.be.null
        expect(response.name).to.equal('new project')
        expect(response.publicKey).to.have.length(32)
        expect(response.plan).to.equal('enterprise')
        done()
