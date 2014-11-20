cloudfront = Cine.server_lib("aws/cloudfront")
shortId = require('shortid')
describe 'cloudfront', ->

  describe 'createDistribution', ->
    beforeEach ->
      @shortIDSpy = sinon.stub(shortId, 'generate').returns("short-id-generated")
    afterEach ->
      @shortIDSpy.restore()

    describe 'default options', ->
      beforeEach ->
        fixture = requireFixture('nock/create_cloudfront_distribution')
        @cloudfrontNock = fixture(callerReference: 'short-id-generated', origin: "test-origin.cine.io")
      it 'creates a distribution', (done)->
        cloudfront.createDistribution "test-origin.cine.io", (err, response)=>
          expect(err).to.be.null
          expect(response.Id).to.equal('EQGIDG4E7DZCZ')
          expect(@cloudfrontNock.isDone()).to.be.true
          done()

    describe 'with options', ->
      beforeEach ->
        fixture = requireFixture('nock/create_cloudfront_distribution')
        @cloudfrontNock = fixture(logging: {bucket: 'hls-logging.s3.amazonaws.com', prefix: 'www-cine'}, callerReference: 'short-id-generated', origin: "test-origin.cine.io")

      it 'creates a with options', (done)->
        options =
          logging:
            bucket: 'hls-logging.s3.amazonaws.com'
            prefix: 'www-cine'
        cloudfront.createDistribution "test-origin.cine.io", options, (err, response)=>
          expect(err).to.be.null
          expect(@cloudfrontNock.isDone()).to.be.true
          expect(response.Id).to.equal('EQGIDG4E7DZCZ')
          done()
  describe 'getDistribution', ->
    beforeEach ->
      @cloudfrontNock = requireFixture('nock/get_cloudfront_distribution')(id: 'EQGIDG4E7DZCZ')

    it 'creates a distribution', (done)->
      cloudfront.getDistribution "EQGIDG4E7DZCZ", (err, response)=>
        expect(err).to.be.null
        expect(response.Id).to.equal('E3A4KOLOH12OAV')
        expect(@cloudfrontNock.isDone()).to.be.true
        done()
