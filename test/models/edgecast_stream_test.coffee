EdgecastStream = SS.model('edgecast_stream')
Organization = SS.model('organization')
modelTimestamps = SS.require('test/helpers/model_timestamps')
_ = require('underscore')

describe 'EdgecastStream', ->
  modelTimestamps EdgecastStream

  describe '.nextAvailable', ->
    beforeEach resetMongo
    beforeEach (done)->
      @stream1 = new EdgecastStream(streamName: 'name1')
      @stream1.save done

    beforeEach (done)->
      c = new Date
      c.setMonth(c.getMonth + 1)
      @stream2 = new EdgecastStream(streamName: 'name2', instanceName: 'my-instance', createdAt: c)
      @stream2.save done

    it 'returns a the next available stream by createdAt ', (done)->
      streamIds = _.invoke([@stream1._id, @stream2._id], 'toString')
      EdgecastStream.nextAvailable (err, availableStream)=>
        expect(availableStream._id.toString()).to.equal(@stream1._id.toString())
        done(err)

    it 'does not return consumed streams', (done)->
      @stream1._organization = (new Organization)._id
      @stream1.save (err)=>
        expect(err).to.be.null
        EdgecastStream.nextAvailable (err, availableStream)=>
          expect(availableStream._id.toString()).to.equal(@stream2._id.toString())
          done(err)
