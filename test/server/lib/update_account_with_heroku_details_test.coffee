updateAccountWithHerokuDetails = Cine.server_lib('update_account_with_heroku_details')
Account = Cine.server_model('account')

describe 'updateAccountWithHerokuDetails', ->
  it 'errs without an account', (done)->
    updateAccountWithHerokuDetails {}, (err)->
      expect(err).to.equal("accountId not passed in")
      done()

  it 'errs when it cannot find an account', (done)->
    account = new Account
    console.log("new account", account)
    updateAccountWithHerokuDetails accountId: account._id, (err)->
      expect(err).to.equal("account not found for id: #{account._id}")
      done()

  describe 'success', ->

    beforeEach (done)->
      @account = new Account(billingProvider: 'heroku', herokuId: "app29975387@heroku.com")
      @account.save done

    beforeEach ->
      @herokuDetailsNock = requireFixture('nock/get_heroku_account_details')()

    it 'updates with heroku credentials', (done)->
      updateAccountWithHerokuDetails accountId: @account._id, (err)=>
        expect(err).to.be.null
        Account.findById @account._id, (err, account)->
          expect(err).to.be.null
          expect(account.billingEmail).to.equal('thomas@cine.io')
          expect(account.herokuData).to.deep.equal({"callback_url":"https://api.heroku.com/vendor/apps/app29975387%40heroku.com","config":{"CINE_IO_PUBLIC_KEY":"THE PUB KEY","CINE_IO_SECRET_KEY":"THE SECRET KEY"},"domains":["cineio-node-example.herokuapp.com"],"id":"app29975387@heroku.com","name":"cineio-node-example","owner_email":"thomas@cine.io","region":"amazon-web-services::us-east-1","logplex_token":"t.b7b8e1b3-ebd2-4d3a-ae30-614fe9520767"})
          done()
