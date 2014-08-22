TextMongooseErrorMessage = Cine.server_lib('text_mongoose_error_message')
Account = Cine.server_model('account')
mongoose = require('mongoose')
describe 'TextMongooseErrorMessage', ->

  RandomModelSchema = new mongoose.Schema
    name:
      type: String
      required: true
  RandomModel = mongoose.model 'RandomModel', RandomModelSchema

  it 'transforms error messages', (done)->
    e = new RandomModel
    e.save (err)->
      expect(err).not.to.be.null
      expect(TextMongooseErrorMessage(err)).to.equal('name is required.')
      done()
