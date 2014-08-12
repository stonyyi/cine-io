fixEdgecastCodecsOnNewStreamRecordings = Cine.server_lib('stream_recordings/fix_edgecast_codecs_on_new_stream_recordings')
FakeFtpClient = Cine.require('test/helpers/fake_ftp_client')

describe 'fixEdgecastCodecsOnNewStreamRecordings', ->

  beforeEach ->
    @fakeFtpClient = new FakeFtpClient

    @listStub = sinon.stub()

    # listStub allows for me to specify
    # stub().withArgs("/the/dir")
    # because the actual list call takes ("/the/dir", callback)
    # and you can't use sinon's .withArgs(string, callback)
    # because you do not have the exact callback function
    # so the withArgs call does not match
    @fakeFtpClient.stub 'list', (directory, callback)=>
      callback null, @listStub(directory)
    list = [
      {
      type: 'd',
      name: 'mynewdir',
      target: undefined,
      rights: { user: 'rwx', group: 'rx', other: 'rx' },
      owner: '65534',
      group: 'nogroup',
      size: 59,
      date: "Thu Jul 31 2014 23:08:00 GMT+0000 (UTC)"
      }, {
        type: '-',
        name: 'exampleStream.mp4',
        target: undefined,
        rights: { user: 'rw', group: 'rw', other: 'r' },
        owner: '65534',
        group: 'nogroup',
        size: 4684422,
        date: "Wed Jul 16 2014 20:34:00 GMT+0000 (UTC)"
      }, {
        type: '-',
        name: 'exampleStream.1.mp4',
        target: undefined,
        rights: { user: 'rw', group: 'rw', other: 'r' },
        owner: '65534',
        group: 'nogroup',
        size: 4684422,
        date: "Wed Jul 16 2014 20:34:00 GMT+0000 (UTC)"
      }
    ]
    @listStub.withArgs('/ready_to_fix').returns(list)
    @listStub.withArgs('/fixed_recordings')
      .onFirstCall().returns([])
      .onSecondCall().returns(list.slice(1,2))

  afterEach ->
    @fakeFtpClient.restore()

  beforeEach ->
    @mkdirStub = @fakeFtpClient.stub('mkdir')
    directoryAlreadyExists = new Error("Can't create directory: File exists")
    directoryAlreadyExists.code = 550
    @mkdirStub.withArgs('/fixed_recordings')
      .onFirstCall().callsArgWith(1, null)
      .onSecondCall().callsArgWith(1, directoryAlreadyExists)

  beforeEach ->
    @putStub = @fakeFtpClient.stub('put').callsArg(2)

  beforeEach ->
    @scheduleProcessFixedRecordingsNock = requireFixture('nock/schedule_ironio_worker')('stream_recordings/process_fixed_recordings').nock

  beforeEach ->
    @deleteStub = @fakeFtpClient.stub('delete')
    @deleteStub.withArgs('/ready_to_fix/exampleStream.mp4').callsArgWith 1, null
    @deleteStub.withArgs('/ready_to_fix/exampleStream.1.mp4').callsArgWith 1, null

  it 'downloads the files and reuploads them to /fixed_recordings', (done)->
    fixEdgecastCodecsOnNewStreamRecordings (err)=>
      expect(err).to.be.null
      expect(@mkdirStub.callCount).to.equal(2)
      expect(@listStub.callCount).to.equal(3)
      expect(@putStub.callCount).to.equal(2)
      calledWithFirstStream = @putStub.calledWith(Cine.path("/tmp/fixed_edgecast_recordings/exampleStream.mp4"), "/fixed_recordings/exampleStream.mp4")
      expect(calledWithFirstStream).to.be.true
      calledWithSecondStream = @putStub.calledWith(Cine.path("/tmp/fixed_edgecast_recordings/exampleStream.1.mp4"), "/fixed_recordings/exampleStream.1.mp4")
      expect(calledWithSecondStream).to.be.true
      done()

  it 'schedules a worker if there are new recordings', (done)->
    fixEdgecastCodecsOnNewStreamRecordings (err)=>
      expect(err).to.be.null
      expect(@scheduleProcessFixedRecordingsNock.isDone()).to.be.true
      done()

  it 'deletes all broken recordings after fixing them', (done)->
    fixEdgecastCodecsOnNewStreamRecordings (err)=>
      expect(err).to.be.null
      expect(@deleteStub.callCount).to.equal(2)
      done()
