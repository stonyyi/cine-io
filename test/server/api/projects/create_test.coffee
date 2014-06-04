Project = Cine.server_model('project')
ProjectCreate = Cine.api('projects/create')
Create = testApi ProjectCreate
User = Cine.server_model('user')
stubEdgecast = Cine.require 'test/helpers/stub_edgecast'
EdgecastStream = Cine.server_model('edgecast_stream')

describe 'Projects#Create', ->
  testApi.requresLoggedIn Create

  beforeEach (done)->
    @user = new User(name: 'my name', email: 'my email', plan: 'free')
    @user.save done

  describe 'success', ->

    it 'creates an project', (done)->
      params = name: 'new project'
      Create params, user: @user, (err, response, options)->
        expect(err).to.be.null
        expect(response.name).to.equal('new project')
        expect(response.publicKey).to.have.length(32)
        done()

    it 'adds the permission to the user', (done)->
      params = name: 'new project'
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
      params = name: 'new project', createStream: 'true'
      Create params, user: @user, (err, response, options)->
        expect(err).to.be.null
        expect(response.name).to.equal('new project')
        expect(response.publicKey).to.have.length(32)
        done()

  describe 'addExampleProjectToUser', ->
    beforeEach (done)->
      @stream = new EdgecastStream(instanceName: 'cines', streamName: 'cine1', streamKey: 'bass35', eventName: 'cine1ENAME')
      @stream.save done

    stubEdgecast()

    it 'adds a stream to the new project', (done)->
      ProjectCreate.addExampleProjectToUser @user, (err, response, options)=>
        expect(err).to.be.null
        expect(response.name).to.equal('Development')
        expect(response.streamsCount).to.equal(1)
        expect(response.publicKey).to.have.length(32)
        EdgecastStream.findById @stream.id, (err, stream)->
          expect(err).to.be.null
          expect(stream._project.toString()).to.equal(response.id.toString())
          expect(stream.name).to.equal('Test')
          done()
