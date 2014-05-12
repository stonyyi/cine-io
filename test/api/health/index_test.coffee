Index = testApi Cine.api('health/index')

describe 'Health#Index', ->

  it 'says ok', (done)->
    Index (err, response, options)=>
      expect(err).to.be.null
      expect(response).to.deep.equal(status: 'OK')
      done()
