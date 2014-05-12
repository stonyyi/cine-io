Organization = Cine.model('organization')
modelTimestamps = Cine.require('test/helpers/model_timestamps')

describe 'Organization', ->
  modelTimestamps(Organization, name: 'hey')

  describe 'api_key', ->
    it 'has a unique api_key generated on save', (done)->
      org = new Organization(name: 'some name')
      org.save (err)->
        expect(err).to.be.null
        expect(org.apiKey.length).to.equal(48)
        done()

    it 'will not override the password change request on future saves', (done)->
      org = new Organization(name: 'some name')
      org.save (err)->
        expect(err).to.be.null
        apiKey = org.apiKey
        expect(apiKey.length).to.equal(48)
        org.save (err)->
          expect(org.apiKey).to.equal(apiKey)
          done(err)
