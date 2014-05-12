createNewStreamInEdgecast = Cine.lib('create_new_stream_in_edgecast')
EdgecastStream = Cine.model('edgecast_stream')
stubEdgecast = Cine.require 'test/helpers/stub_edgecast'

describe 'createNewStreamInEdgecast', ->
  beforeEach resetMongo
  beforeEach (done)->
    @stream1 = new EdgecastStream(streamName: 'name1')
    @stream1.save done

  stubEdgecast()

  it 'calls to edgecast and creates a new EdgecastStream in the db', (done)->
    createNewStreamInEdgecast (err, stream)->
      expect(err).to.be.null
      expect(stream.streamName).to.equal('cine2')
      expect(stream.eventName).to.equal('cine2')
      expect(stream.instanceName).to.equal('cines')
      d = new Date
      expect(stream.expiration.getDate()).to.equal(d.getDate())
      expect(stream.expiration.getMonth()).to.equal(d.getMonth())
      expect(stream.expiration.getFullYear()).to.equal(d.getFullYear()+20)
      done()
