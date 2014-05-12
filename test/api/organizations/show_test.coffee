Organization = Cine.model('organization')
Show = testApi Cine.api('organizations/show')

describe 'Organizations#Show', ->
  testApi.requresApiKey Show

  beforeEach (done)->
    @org = new Organization(name: 'my org')
    @org.save done

  it 'returns an org', (done)->
    params = apiKey: @org.apiKey
    Show params, (err, response, options)=>
      expect(err).to.be.null
      expect(response._id.toString()).to.equal(@org._id.toString())
      expect(response.name).to.equal('my org')
      done()
