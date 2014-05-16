PasswordChangeRequest = Cine.server_model('password_change_request')
modelTimestamps = Cine.require('test/helpers/model_timestamps')

describe 'PasswordChangeRequest', ->
  modelTimestamps PasswordChangeRequest, {}

  it 'has a unique identifier generated on save', (done)->
    pcr = new PasswordChangeRequest
    pcr.save (err)->
      expect(err).to.be.null
      expect(pcr.identifier.length).to.equal(48)
      done()

  it 'will not override the password change request on future saves', (done)->
    pcr = new PasswordChangeRequest
    pcr.save (err)->
      expect(err).to.be.null
      identifier = pcr.identifier
      expect(identifier.length).to.equal(48)
      pcr.save (err)->
        expect(pcr.identifier).to.equal(identifier)
        done(err)
