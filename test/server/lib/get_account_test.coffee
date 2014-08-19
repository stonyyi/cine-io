getAccount = Cine.server_lib('get_account')
Account = Cine.server_model('account')
_ = require('underscore')

describe 'getAccount', ->

  beforeEach (done)->
    @account = new Account(tempPlan: 'solo')
    @account.save done

  it 'requires a masterKey', (done)->
    getAccount {}, (err, account, options)->
      expect(err).to.equal('masterKey not supplied')
      expect(account).to.be.null
      expect(options).to.deep.equal(status: 401)
      done()

  it 'can take a masterKey', (done)->
    getAccount masterKey: @account.masterKey, (err, account, options)=>
      expect(err).to.be.null
      expect(options).to.be.undefined
      expect(account._id.toString()).to.equal(@account._id.toString())
      done()

  it 'returns 404 when not found', (done)->
    getAccount masterKey: (new Account)._id, (err, account, options)->
      expect(err).to.equal('account not found')
      expect(account).to.be.null
      expect(options).to.deep.equal(status: 404)
      done()
