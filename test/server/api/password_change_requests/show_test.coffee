PasswordChangeRequest = Cine.server_model('password_change_request')
FetchPasswordChangeRequest = Cine.api('password_change_requests/show')

describe 'PasswordChangeRequests#Show', ->

  it "requires an identifier", (done)->
    params = {}
    callback = (err, response, options)->
      expect(err).to.equal('missing identifier')
      expect(options.status).to.equal(400)
      done()

    FetchPasswordChangeRequest params, callback

  it "must match identifiers", (done)->
    params = identifier: -1
    callback = (err, response, options)->
      expect(err).to.equal('not found')
      expect(options.status).to.equal(400)
      done()

    FetchPasswordChangeRequest params, callback

  it "finds the password change request", (done)->
    pcr = new PasswordChangeRequest
    pcr.save (err)->
      expect(err).to.be.null
      expect(pcr.identifier).to.not.be.null
      params = identifier: pcr.identifier
      callback = (err, response)->
        expect(err).to.be.null
        expect(response.id.toString()).to.equal(pcr._id.toString())
        done()

      FetchPasswordChangeRequest params, callback
