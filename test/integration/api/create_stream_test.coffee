app = Cine.require('app').app
supertest = require('supertest')
User = Cine.server_model('user')
Project = Cine.server_model('project')
EdgecastStream = Cine.server_model('edgecast_stream')
stubEdgecast = Cine.require 'test/helpers/stub_edgecast'
_ = require('underscore')
login = Cine.require 'test/helpers/login_helper'

describe 'create stream', ->

  beforeEach (done)->
    @project = new Project(name: 'my project')
    @project.save done

  beforeEach (done)->
    @stream = new EdgecastStream(instanceName: 'this-instance')
    @stream.save done

  beforeEach (done)->
    @user = new User(email: 'the email', name: 'Thomas', plan: 'test')
    @user.permissions.push objectId: @project._id, objectName: 'Project'
    @user.assignHashedPasswordAndSalt 'the pass', (err)=>
      @user.save done

  beforeEach ->
    @agent = supertest.agent(app)

  stubEdgecast()

  beforeEach (done)->
    login(@agent, @user, 'the pass', done)

  it 'should return a new stream with the correct name', (done)->
    @agent
    .post("/api/1/-/stream?secretKey=#{@project.secretKey}&name=support+test")
    .expect('Content-Type', /json/)
    .expect(200)
    .end (err, res)=>
      expect(err).to.be.null
      streamResponse = JSON.parse(res.text)
      expect(streamResponse.id).to.equal(@stream._id.toString())
      expect(streamResponse.name).to.equal("support test")
      expect(_.keys(streamResponse)).to.include('assignedAt')
      done()
