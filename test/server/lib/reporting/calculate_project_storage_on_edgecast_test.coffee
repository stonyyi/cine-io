_ = require 'underscore'
edgecastFtpClientFactory = Cine.server_lib('edgecast_ftp_client_factory')
CalculateProjectStorageOnEdgecast = Cine.server_lib('reporting/calculate_project_storage_on_edgecast')
Project = Cine.server_model("project")
FakeFtpClient = Cine.require('test/helpers/fake_ftp_client')

describe 'CalculateProjectStorageOnEdgecast', ->
  describe '.total', ->

    describe "success", ->
      beforeEach (done)->
        @project1 = new Project(publicKey: 'proj-pub-key')
        @project1.save done

      beforeEach ->
        @fakeFtpClient = new FakeFtpClient

        @listStub = sinon.stub()

        # listStub allows for me to specify
        # stub().withArgs("/the/dir")
        # because the actual list call takes ("/the/dir", callback)
        # and you can't use sinon's .withArgs(string, callback)
        # because you do not have the exact callback function
        # so the withArgs call does not match
        @fakeFtpClient.stub 'list', (args, callback)=>
          callback null, @listStub(args)
        @lists = Cine.require('test/fixtures/edgecast_stream_recordings')
        @listStub.withArgs('/cines/proj-pub-key').returns(@lists)

      afterEach ->
        @fakeFtpClient.restore()

      it 'calculates the project storage for a project', (done)->
        CalculateProjectStorageOnEdgecast.total @project1, (err, sizeInBytes)->
          expect(err).to.be.null
          expect(sizeInBytes).to.equal(124854040)
          done()
