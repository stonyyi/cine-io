EdgecastParsedLog = Cine.server_model('edgecast_parsed_log')
modelTimestamps = Cine.require('test/helpers/model_timestamps')

describe 'EdgecastParsedLog', ->
  modelTimestamps EdgecastParsedLog, name: 'some name'

  describe 'defaults', ->
    describe 'isComplete', ->
      it 'defaults to false', ->
        epl = new EdgecastParsedLog
        expect(epl.isComplete).to.be.false
