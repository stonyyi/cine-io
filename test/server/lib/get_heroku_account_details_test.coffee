getHerokuAccountDetails = Cine.server_lib('get_heroku_account_details')
Account = Cine.server_model('account')
herokuConfig = Cine.config('variables/heroku')

describe 'getHerokuAccountDetails', ->

  beforeEach (done)->
    @account = new Account(herokuId: "app29975387@heroku.com")
    @account.save done

  beforeEach ->
    @oldssoSalt = herokuConfig.ssoSalt
    @oldusername = herokuConfig.username
    @oldpassword = herokuConfig.password
    herokuConfig.ssoSalt = "test-ssoSalt"
    herokuConfig.username = "test-username"
    herokuConfig.password = "test-password"

  afterEach ->
    herokuConfig.ssoSalt = @oldssoSalt
    herokuConfig.username = @oldusername
    herokuConfig.password = @oldpassword

  beforeEach ->
    @herokuDetailsNock = requireFixture('nock/get_heroku_account_details')()

  it 'fetches the heroku details', (done)->
    getHerokuAccountDetails @account, (err, results)=>
      expect(err).to.be.null
      expect(results).to.deep.equal({"callback_url":"https://api.heroku.com/vendor/apps/app29975387%40heroku.com","config":{"CINE_IO_PUBLIC_KEY":"THE PUB KEY","CINE_IO_SECRET_KEY":"THE SECRET KEY"},"domains":["cineio-node-example.herokuapp.com"],"id":"app29975387@heroku.com","name":"cineio-node-example","owner_email":"thomas@cine.io","region":"amazon-web-services::us-east-1","logplex_token":"t.b7b8e1b3-ebd2-4d3a-ae30-614fe9520767"})
      expect(@herokuDetailsNock.isDone()).to.be.true
      done()
