TextMongooseErrorMessage = Cine.server_lib('text_mongoose_error_message')
Account = Cine.server_model('account')

describe 'TextMongooseErrorMessage', ->

  it 'transforms error messages', (done)->
    e = new Account
    e.save (err)->
      expect(err).not.to.be.null
      expect(TextMongooseErrorMessage(err)).to.equal('tempPlan is required.')
      done()
