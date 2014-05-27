Root = testApi Cine.api('root')

describe 'Root', ->

  it 'says ok', (done)->
    Root (err, response, options)->
      expect(err).to.be.null
      expect(response).to.deep.equal(msg: 'Welcome to Cine.io API root url.')
      done()
