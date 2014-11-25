ParsedLog = Cine.server_model('parsed_log')
modelTimestamps = Cine.require('test/helpers/model_timestamps')

describe 'ParsedLog', ->
  modelTimestamps ParsedLog, name: 'some name'

  describe 'defaults', ->
    describe 'isComplete', ->
      it 'defaults to false', ->
        epl = new ParsedLog
        expect(epl.isComplete).to.be.false
