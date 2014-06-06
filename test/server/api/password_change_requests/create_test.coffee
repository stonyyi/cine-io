User = Cine.server_model('user')
PasswordChangeRequest = Cine.server_model 'password_change_request'
CreatePasswordChangeRequest = Cine.api('password_change_requests/create')
mailer = Cine.server_lib("mailer")

describe 'PasswordChangeRequests#Create', ->
  it 'requires an email', (done)->
    CreatePasswordChangeRequest {}, (err, response, options)->
      expect(err).to.equal('email required')
      expect(response).to.be.null
      expect(options.status).to.equal(400)
      done()

  it 'errs when the email is not found', (done)->
    CreatePasswordChangeRequest email: 'not found', (err, response, options)->
      expect(err).to.equal('not found')
      expect(response).to.be.null
      expect(options.status).to.equal(404)
      done()

  # returning the PCR would defeat the purpose of hiding the identifier
  it "creates a password change request and does NOT return it", (done)->
    sinon.stub(mailer, "forgotPassword")

    u = new User name: 'Mah name', email: 'thomas@cine.io', plan: 'startup'
    u.save (err)->
      expect(err).to.equal(null)
      params = {email: 'thomas@cine.io'}
      callback = (err, response)->
        expect(err).to.equal(null)
        expect(response).to.deep.equal({})
        PasswordChangeRequest.findOne _user: u._id, (err, pcr)->
          expect(pcr.identifier).not.to.be.null
          expect(mailer.forgotPassword.calledOnce).to.be.true
          args = mailer.forgotPassword.firstCall.args
          expect(args[0]._id.toString()).to.equal(u._id.toString())
          expect(args[1]._id.toString()).to.equal(pcr._id.toString())
          done()

      CreatePasswordChangeRequest params, callback
