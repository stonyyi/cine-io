Project = Cine.server_model('project')
ProjectCreate = Cine.api('projects/create')
Create = testApi ProjectCreate
Account = Cine.server_model('account')
stubEdgecast = Cine.require 'test/helpers/stub_edgecast'
EdgecastStream = Cine.server_model('edgecast_stream')
TurnUser = Cine.server_model('turn_user')
_ = require('underscore')

describe 'Projects#Create', ->
  testApi.requiresMasterKey Create

  beforeEach (done)->
    @account = new Account(billingProvider: 'cine.io', plans: ['free'], masterKey: 'mk1')
    @account.save done

  describe 'success', ->

    it 'creates a project', (done)->
      params = name: 'new project'
      Create _.extend(masterKey: 'mk1', params), (err, response, options)->
        expect(err).to.be.null
        expect(response.name).to.equal('new project')
        expect(response.publicKey).to.have.length(32)
        done()

    it 'creates a turn user', (done)->
      params = name: 'new project'
      Create _.extend(masterKey: 'mk1', params), (err, response, options)->
        expect(err).to.be.null
        TurnUser.findOne _project: response.id, (err, tu)->
          expect(err).to.be.null
          expect(tu.name).to.equal(response.publicKey)
          expect(tu.realm).to.equal('cine.io')
          expect(tu.hmackey).to.be.ok
          done()

    it 'adds the account to the project', (done)->
      params = name: 'new project'
      Create _.extend(masterKey: 'mk1', params), (err, response, options)=>
        Project.findById response.id, (err, project)=>
          expect(err).to.be.null
          expect(project._account.toString()).to.equal(@account._id.toString())
          done()

  describe 'with adding as stream', ->
    beforeEach (done)->
      @stream = new EdgecastStream(instanceName: 'cines', streamName: 'cine1', streamKey: 'bass35', eventName: 'cine1ENAME')
      @stream.save done

    stubEdgecast()

    it 'adds a stream to the new project', (done)->
      params = name: 'new project', createStream: 'true'
      Create _.extend(masterKey: 'mk1', params), (err, response, options)->
        expect(err).to.be.null
        expect(response.name).to.equal('new project')
        expect(response.publicKey).to.have.length(32)
        done()
