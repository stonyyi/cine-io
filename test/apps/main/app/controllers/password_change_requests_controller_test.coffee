RecoverPasswords = Cine.controller 'password_change_requests'
ControllerTester = Cine.require('test/helpers/test_controller_action')
test = ControllerTester(RecoverPasswords)

describe 'RecoverPasswords', ->
  beforeEach ->
    RecoverPasswords.app = mainApp
    @fetchStub = sinon.stub mainApp, "fetch", (spec, callback)->
      expect(spec).to.deep.equal(model: {model: 'PasswordChangeRequest', params: {identifier: 'the ident'}})
      callback(null, 'the pcr')

  afterEach ->
    delete RecoverPasswords.app
    @fetchStub.restore()

  describe '#show', ->
    it 'fetches the password change request', (done)->
      params = identifier: 'the ident'
      callback = (err, result)->
        expect(err).to.equal(null)
        expect(result).to.equal('the pcr')
        done()
      test('show', params, callback)
