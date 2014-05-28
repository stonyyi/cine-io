Show = testApi Cine.api('static-document/show')

describe 'StaticDocument#show', ->

  it 'requires an id', (done)->
    params = {}
    callback = (err, response, options)->
      console.log "response", response
      console.log "options", options
      expect(err).to.equal("id required")
      expect(response).to.be.null
      expect(options).to.deep.equal(status: 404)
      done()
    Show(params, callback)

  it 'requires the document exist', (done)->
    params = {id: 'MISSING'}
    callback = (err, response, options)->
      console.log "response", response
      console.log "options", options
      expect(err).to.equal("not found")
      expect(response).to.be.null
      expect(options).to.deep.equal(status: 404)
      done()
    Show(params, callback)

  it 'fetches a document by legal/terms-of-service', (done)->
    params = {id: 'legal/terms-of-service'}
    callback = (err, response, options)->
      expect(err).to.be.null
      expect(options).to.be.undefined
      expect(response.document).to.include("Terms of Use")
      expect(response.id).to.include('legal/terms-of-service')
      done()
    Show(params, callback)