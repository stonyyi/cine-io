Account = Cine.server_model('account')
_ = require('underscore')
modelTimestamps = Cine.require('test/helpers/model_timestamps')

describe 'Account', ->
  modelTimestamps(Account, name: 'hey')

  describe 'masterKey', ->
    it 'has a unique masterKey generated on save', (done)->
      account = new Account(name: 'some name')
      account.save (err)->
        expect(err).to.be.null
        expect(account.masterKey.length).to.equal(64)
        done()

    it 'will not override the masterKey on future saves', (done)->
      account = new Account(name: 'some name')
      account.save (err)->
        expect(err).to.be.null
        masterKey = account.masterKey
        expect(masterKey.length).to.equal(64)
        account.save (err)->
          expect(account.masterKey).to.equal(masterKey)
          done(err)
