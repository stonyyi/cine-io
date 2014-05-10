RememberMeToken = SS.model('remember_me_token')
modelTimestamps = SS.require('test/helpers/model_timestamps')

describe 'RememberMeToken', ->
  modelTimestamps RememberMeToken, {}
  beforeEach resetMongo
  it 'has a unique token generated on save', (done)->
    rmt = new RememberMeToken
    rmt.save (err)->
      expect(err).to.be.null
      expect(rmt.token.length).to.equal(64)
      done()

  it 'will not override the token on the next save', (done)->
    rmt = new RememberMeToken
    rmt.save (err)->
      expect(err).to.be.null
      token = rmt.token
      expect(token.length).to.equal(64)
      rmt.save (err)->
        expect(rmt.token).to.equal(token)
        done(err)
