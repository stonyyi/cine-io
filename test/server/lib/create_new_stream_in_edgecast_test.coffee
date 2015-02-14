createNewStreamInEdgecast = Cine.server_lib('create_new_stream_in_edgecast')
EdgecastStream = Cine.server_model('edgecast_stream')
stubEdgecast = Cine.require 'test/helpers/stub_edgecast'

describe 'createNewStreamInEdgecast', ->

  describe 'creating a new stream', ->
    beforeEach (done)->
      stream1 = new EdgecastStream(instanceName: 'cines', streamName: 'name1')
      stream1.save done

    beforeEach (done)->
      stream2 = new EdgecastStream(instanceName: 'bobs', streamName: 'name2')
      stream2.save done

    stubEdgecast(streamName: 'yoooo')

    it 'calls to edgecast and creates a new EdgecastStream in the db', (done)->
      createNewStreamInEdgecast (err, stream)->
        expect(err).to.be.null
        expect(stream.streamName).to.equal('yoooo')
        expect(stream.eventName).to.equal('yoooo')
        expect(stream.instanceName).to.equal('cines')
        d = new Date
        expect(stream.expiration.getDate()).to.equal(d.getDate())
        expect(stream.expiration.getMonth()).to.equal(d.getMonth())
        expect(stream.expiration.getFullYear()).to.equal(d.getFullYear()+20)
        done()
