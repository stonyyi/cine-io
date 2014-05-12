Organization = Cine.model('organization')
Create = testApi Cine.api('organizations/create')

describe 'Organizations#Create', ->

  it 'creates an organization', (done)->
    params = name: 'new org'
    Create params, (err, response, options)->
      expect(err).to.be.null
      expect(response.name).to.equal('new org')
      expect(response.apiKey).to.have.length(48)
      done()
