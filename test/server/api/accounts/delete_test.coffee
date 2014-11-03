DeleteAccount = testApi Cine.api('accounts/delete')
deleteAccount = Cine.server_lib('delete_account')
Account = Cine.server_model('account')
User = Cine.server_model('user')

describe 'Accounts#delete', ->
  testApi.requiresMasterKey DeleteAccount

  beforeEach (done)->
    @account = new Account(billingProvider: 'heroku', plans: ['pro'], billingEmail: 'the email', name: 'Chillin')
    @account.save done

  it 'cannot delete non cine.io accounts through the ui, they must be done through the billing provider', (done)->
    params = {masterKey: @account.masterKey}
    callback = (err, response, options)->
      expect(err).to.equal('cannot delete non cine.io accounts')
      expect(response).to.be.null
      expect(options).to.deep.equal(status: 400)
      done()

    DeleteAccount params, callback

  describe 'success', ->
    beforeEach (done)->
      @account.billingProvider = 'cine.io'
      @account.save done

    it 'deletes cine.io accounts', (done)->
      params = {masterKey: @account.masterKey}
      callback = (err, response, options)=>
        expect(err).to.be.null
        expect(response.deletedAt).to.be.instanceOf(Date)
        expect(response.id.toString()).to.equal(@account._id.toString())
        expect(options).to.be.undefined
        done()

      DeleteAccount params, callback
