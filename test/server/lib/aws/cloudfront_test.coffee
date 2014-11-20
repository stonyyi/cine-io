cloudfront = Cine.server_lib("aws/cloudfront")
shortId = require('shortid')

describe 'cloudfront', ->

  beforeEach ->
    @shortIDSpy = sinon.stub(shortId, 'generate').returns("short-id-generated")
  afterEach ->
    @shortIDSpy.restore()

  describe 'ensureDistributionForOrigin', ->
    describe 'with an existing deployed distro', ->
      beforeEach ->
        @cloudfrontNock = requireFixture('nock/cloudfront/list_cloudfront_distributions')()

      it 'returns a distro if it is deployed', (done)->
        cloudfront.ensureDistributionForOrigin "cine-io-production.s3.amazonaws.com", (err, distro)=>
          expect(err).to.be.null
          expect(distro.Id).to.equal("E3A4KOLOH12OAV")
          expect(@cloudfrontNock.isDone()).to.be.true
          done()

    describe 'with an existing distro that is new', ->
      beforeEach ->
        @cloudfrontNock = requireFixture('nock/cloudfront/list_cloudfront_distributions')()
        @cloudfrontNock2 = requireFixture('nock/cloudfront/get_cloudfront_distribution')(id: 'E3T3CQG8HMMR6N')

      it 'waits for the distro to be deployed if being created now', (done)->
        cloudfront.ensureDistributionForOrigin "cine-io-hls.s3.amazonaws.com", (err, distro)=>
          console.log("DONE")
          expect(err).to.be.null
          expect(distro.Id).to.equal("E3A4KOLOH12OAV")
          expect(@cloudfrontNock.isDone()).to.be.true
          expect(@cloudfrontNock2.isDone()).to.be.true
          done()

    describe 'without an existing distro', ->
      beforeEach ->
        fixture = requireFixture('nock/cloudfront/create_cloudfront_distribution')
        @cloudfrontNock = fixture(callerReference: 'short-id-generated', origin: "test-origin.cine.io")
        @cloudfrontNock2 = requireFixture('nock/cloudfront/get_cloudfront_distribution')(id: 'EQGIDG4E7DZCZ')

      it 'creates a new distro and waits for the distro to be deployed', (done)->
        cloudfront.ensureDistributionForOrigin "test-origin.cine.io", (err, distro)=>
          expect(err).to.be.null
          expect(distro.Id).to.equal("E3A4KOLOH12OAV")
          expect(@cloudfrontNock.isDone()).to.be.true
          expect(@cloudfrontNock2.isDone()).to.be.true
          done()

    describe 'without an existing distro and options', ->
      beforeEach ->
        fixture = requireFixture('nock/cloudfront/create_cloudfront_distribution')
        @cloudfrontNock = fixture(logging: {bucket: 'hls-logging.s3.amazonaws.com', prefix: 'www-cine'}, callerReference: 'short-id-generated', origin: "test-origin.cine.io")
        @cloudfrontNock2 = requireFixture('nock/cloudfront/get_cloudfront_distribution')(id: 'EQGIDG4E7DZCZ')

      it 'creates a new distro and waits for the distro to be deployed', (done)->
        options =
          logging:
            bucket: 'hls-logging.s3.amazonaws.com'
            prefix: 'www-cine'

        cloudfront.ensureDistributionForOrigin "test-origin.cine.io", options, (err, distro)=>
          expect(err).to.be.null
          expect(distro.Id).to.equal("E3A4KOLOH12OAV")
          expect(@cloudfrontNock.isDone()).to.be.true
          expect(@cloudfrontNock2.isDone()).to.be.true
          done()

  describe 'distrubtionForOrigin', ->
    beforeEach ->
      @cloudfrontNock = requireFixture('nock/cloudfront/list_cloudfront_distributions')()

    it 'finds a distribution for the origin', (done)->
      cloudfront.distrubtionForOrigin "cine-io-production.s3.amazonaws.com", (err, distro)=>
        expect(err).to.be.null
        expect(distro.Id).to.equal("E3A4KOLOH12OAV")
        expect(@cloudfrontNock.isDone()).to.be.true
        done()

    it 'returns null if there is no distro', (done)->
      cloudfront.distrubtionForOrigin "NO_DISTRO", (err, distro)=>
        expect(err).to.be.null
        expect(distro).to.be.undefined
        expect(@cloudfrontNock.isDone()).to.be.true
        done()


  describe 'listDistributions', ->
    beforeEach ->
      @cloudfrontNock = requireFixture('nock/cloudfront/list_cloudfront_distributions')()

    it 'lists the distribution', (done)->
      cloudfront.listDistributions (err, response)=>
        expect(err).to.be.null
        expect(response.Quantity).to.equal(2)
        expect(response.Items[0].Id).to.equal("E3A4KOLOH12OAV")
        expect(response.Items[1].Id).to.equal("E3T3CQG8HMMR6N")
        expect(@cloudfrontNock.isDone()).to.be.true
        done()

  describe 'createDistribution', ->
    describe 'default options', ->
      beforeEach ->
        fixture = requireFixture('nock/cloudfront/create_cloudfront_distribution')
        @cloudfrontNock = fixture(callerReference: 'short-id-generated', origin: "test-origin.cine.io")

      it 'creates a distribution', (done)->
        cloudfront.createDistribution "test-origin.cine.io", (err, response)=>
          expect(err).to.be.null
          expect(response.Id).to.equal('EQGIDG4E7DZCZ')
          expect(@cloudfrontNock.isDone()).to.be.true
          done()

    describe 'with options', ->
      beforeEach ->
        fixture = requireFixture('nock/cloudfront/create_cloudfront_distribution')
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
      @cloudfrontNock = requireFixture('nock/cloudfront/get_cloudfront_distribution')(id: 'EQGIDG4E7DZCZ')

    it 'gets a distribution', (done)->
      cloudfront.getDistribution "EQGIDG4E7DZCZ", (err, response)=>
        expect(err).to.be.null
        expect(response.Id).to.equal('E3A4KOLOH12OAV')
        expect(@cloudfrontNock.isDone()).to.be.true
        done()
