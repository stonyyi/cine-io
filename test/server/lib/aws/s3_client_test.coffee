s3Client = Cine.server_lib('aws/s3_client')

describe 's3Client', ->

  describe 'uploadFile', ->
    beforeEach ->
      @s3ClientSpy = sinon.spy s3Client._s3Client, 'uploadFile'

    afterEach ->
      @s3ClientSpy.restore()

    describe 'failure', ->
      beforeEach ->
        @localFile = Cine.path('test/fixtures/file.txt')
        @s3Bucket = 'cine-io-hls2'
        @s3Nock = requireFixture('nock/aws/upload_file_to_s3_error')("file.txt", "this is a file\n")

      it 'can return an error', (done)->
        s3Client.uploadFile @localFile, @s3Bucket, 'file.txt', (err)=>
          expect(err.code).to.equal('NoSuchBucket')
          expect(@s3Nock.isDone()).to.be.true
          expect(@s3ClientSpy.calledOnce).to.be.true
          done()

    describe 'success', ->
      beforeEach ->
        @localFile = Cine.path('test/fixtures/file.txt')
        @s3Bucket = 'cine-io-hls'
        @s3Nock = requireFixture('nock/aws/upload_file_to_s3_success')("file.txt", "this is a file\n")

      it 'uploads a file to s3', (done)->
        s3Client.uploadFile @localFile, @s3Bucket, 'file.txt', (err)=>
          expect(err).to.be.undefined
          expect(@s3Nock.isDone()).to.be.true
          expect(@s3ClientSpy.calledOnce).to.be.true
          done()

      it 'sets a default ACL', (done)->
        s3Client.uploadFile @localFile, @s3Bucket, 'file.txt', (err)=>
          expect(err).to.be.undefined
          args = @s3ClientSpy.firstCall.args[0]
          expect(args.s3Params.ACL).to.equal('public-read')
          done()

      it 'takes an acl param', (done)->
        s3Client.uploadFile @localFile, @s3Bucket, 'file.txt', ACL: "private", (err)=>
          expect(err).to.be.undefined
          args = @s3ClientSpy.firstCall.args[0]
          expect(args.s3Params.ACL).to.equal('private')
          done()

  describe 'list', ->
    beforeEach ->
      @s3ClientSpy = sinon.spy s3Client._s3Client, 'listObjects'

    afterEach ->
      @s3ClientSpy.restore()

    describe 'failure', ->
      beforeEach ->
        @s3Bucket = 'cine-io-hls2'
        @s3Nock = requireFixture('nock/aws/list_files_s3_error')()

      it 'can return an error', (done)->
        lister = s3Client.list @s3Bucket
        lister.on "error", (err)=>
          expect(err.code).to.equal('NoSuchBucket')
          expect(@s3Nock.isDone()).to.be.true
          expect(@s3ClientSpy.calledOnce).to.be.true
          done()
        lister.on "end", ->
          throw new Error("DONE CALLED BY END, should be on 'error'")

    describe 'success', ->
      beforeEach ->
        @s3Bucket = 'cine-io-hls'

      it 'lists the root directory in s3', (done)->
        @s3Nock = requireFixture('nock/aws/list_files_s3_success')()
        lister = s3Client.list @s3Bucket
        lister.on "error", (err)->
          throw new Error("DONE CALLED BY ERROR, should be on 'end'")
        lister.on 'end', done
        lister.on "data", (data)=>
          expect(data.Contents).to.have.length(4)
          expect(data.CommonPrefixes).to.have.length(9)
          expect(@s3Nock.isDone()).to.be.true
          expect(@s3ClientSpy.calledOnce).to.be.true

      it 'lists a directory in s3', (done)->
        @s3Nock = requireFixture('nock/aws/list_files_s3_success')('f99fb38e8d9e7c752f8547ae9de421bd/')

        lister = s3Client.list @s3Bucket, 'f99fb38e8d9e7c752f8547ae9de421bd/'
        lister.on "error", (err)->
          throw new Error("DONE CALLED BY ERROR, should be on 'end'")
        lister.on 'end', done
        lister.on "data", (data)=>
          expect(data.Contents).to.have.length(4)
          expect(data.CommonPrefixes).to.have.length(9)
          expect(@s3Nock.isDone()).to.be.true
          expect(@s3ClientSpy.calledOnce).to.be.true

  describe 'delete', ->
    beforeEach ->
      @s3ClientSpy = sinon.spy s3Client._s3Client, 'deleteObjects'

    afterEach ->
      @s3ClientSpy.restore()

    describe 'failure', ->
      beforeEach ->
        @s3Bucket = 'cine-io-hls2'
        @s3Nock = requireFixture('nock/aws/delete_file_s3_error')()

      it 'can return an error', (done)->
        s3Client.delete @s3Bucket, '', (err)=>
          expect(err.code).to.equal('NoSuchBucket')
          expect(@s3Nock.isDone()).to.be.true
          expect(@s3ClientSpy.calledOnce).to.be.true
          done()

    describe 'success', ->
      beforeEach ->
        @s3Bucket = 'cine-io-hls'
        @s3Nock = requireFixture('nock/aws/delete_file_s3_success')('cine-io-hls', 'some-stream-1416429958807.ts')

      it 'deletes a file a directory in s3', (done)->
        s3Client.delete @s3Bucket, 'some-stream-1416429958807.ts', (err)=>
          expect(err).to.be.undefined
          expect(@s3Nock.isDone()).to.be.true
          expect(@s3ClientSpy.calledOnce).to.be.true
          done()
