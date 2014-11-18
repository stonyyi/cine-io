uploadFileToS3 = Cine.server_lib('./upload_file_to_s3')

describe 'uploadFileToS3', ->

  beforeEach ->
    @s3ClientSpy = sinon.spy uploadFileToS3._s3Client, 'uploadFile'

  afterEach ->
    @s3ClientSpy.restore()

  describe 'failure', ->
    beforeEach ->
      @localFile = Cine.path('test/fixtures/file.txt')
      @s3Bucket = 'cine-io-hls2'
      @s3Nock = requireFixture('nock/upload_file_to_s3_error')("file.txt", "this is a file\n")

    it 'can return an error', (done)->
      uploadFileToS3 @localFile, @s3Bucket, 'file.txt', (err)=>
        expect(err.code).to.equal('NoSuchBucket')
        expect(@s3Nock.isDone()).to.be.true
        expect(@s3ClientSpy.calledOnce).to.be.true
        done()

  describe 'success', ->
    beforeEach ->
      @localFile = Cine.path('test/fixtures/file.txt')
      @s3Bucket = 'cine-io-hls'
      @s3Nock = requireFixture('nock/upload_file_to_s3_success')("file.txt", "this is a file\n")

    it 'uploads a file to s3', (done)->
      uploadFileToS3 @localFile, @s3Bucket, 'file.txt', (err)=>
        expect(err).to.be.undefined
        expect(@s3Nock.isDone()).to.be.true
        expect(@s3ClientSpy.calledOnce).to.be.true
        done()

    it 'sets a default ACL', (done)->
      uploadFileToS3 @localFile, @s3Bucket, 'file.txt', (err)=>
        expect(err).to.be.undefined
        args = @s3ClientSpy.firstCall.args[0]
        expect(args.s3Params.ACL).to.equal('public-read')
        done()

    it 'takes an acl param', (done)->
      uploadFileToS3 @localFile, @s3Bucket, 'file.txt', ACL: "private", (err)=>
        expect(err).to.be.undefined
        args = @s3ClientSpy.firstCall.args[0]
        expect(args.s3Params.ACL).to.equal('private')
        done()
