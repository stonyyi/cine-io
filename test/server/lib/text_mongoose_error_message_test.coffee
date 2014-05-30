TextMongooseErrorMessage = Cine.server_lib('text_mongoose_error_message')
User = Cine.server_model('user')
describe 'TextMongooseErrorMessage', ->
  beforeEach resetMongo

  it 'transforms error messages', (done)->
    e = new User
    e.save (err)->
      expect(err).not.to.be.null
      expect(TextMongooseErrorMessage(err)).to.equal('plan is required.')
      done()
