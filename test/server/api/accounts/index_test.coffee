Index = testApi Cine.api('accounts/Index')
Account = Cine.server_model('account')
User = Cine.server_model('user')

describe 'Stats#Index', ->
  testApi.requiresSiteAdmin Index

  beforeEach (done)->
    @siteAdmin = new User(isSiteAdmin: true)
    @siteAdmin.save done

  beforeEach (done)->
    @account1 = new Account name: "account1 name"
    @account1.save done

  beforeEach (done)->
    @account2 = new Account name: "account2 name", throttledAt: new Date
    @account2.save done

  beforeEach (done)->
    throttledYesterday = new Date
    throttledYesterday.setDate(throttledYesterday.getDate() - 1)
    @account3 = new Account name: "account3 name", throttledAt: throttledYesterday
    @account3.save done

  describe 'throttled accounts', ->
    it 'returns the throttled accounts stats', (done)->
      params = {throttled: true}
      session = user: @siteAdmin
      callback = (err, response)=>
        expect(err).to.be.null
        expect(response).to.have.length(2)
        expect(response[0].id.toString()).to.equal(@account2._id.toString())
        expect(response[0].name).to.equal(@account2.name)
        expect(response[1].id.toString()).to.equal(@account3._id.toString())
        expect(response[1].name).to.equal(@account3.name)
        done()

      Index params, session, callback

  describe 'other requests', ->
    it "cannot handle other requests", (done)->
      params = {}
      session = user: @siteAdmin
      callback = (err, response, options)->
        expect(err).to.equal("don't know how to respond")
        expect(response).to.be.null
        expect(options).to.deep.equal(status: 400)
        done()

      Index params, session, callback
