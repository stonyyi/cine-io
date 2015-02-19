checkKeenStatus = Cine.server_lib('reporting/check_keen_io_status')

describe 'checkKeenStatus', ->

  describe 'error', ->
    beforeEach ->
      @keenError = requireFixture('nock/keen/status_check_error')()
    it 'returns error when keen is experiencing issues', (done)->
      checkKeenStatus (err)=>
        expect(err).to.equal('keen is experiencing issues')
        expect(@keenError.isDone()).to.be.true
        done()
  describe 'success', ->
    beforeEach ->
      @keenSuccess = requireFixture('nock/keen/status_check_success')()
    it 'returns success when keen is experiencing issues', (done)->
      checkKeenStatus (err)=>
        expect(err).to.be.undefined
        expect(@keenSuccess.isDone()).to.be.true
        done()
