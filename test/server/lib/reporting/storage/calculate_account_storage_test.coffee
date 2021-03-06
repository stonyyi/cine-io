Account = Cine.server_model('account')
Project = Cine.server_model('project')
CalculateAccountStorage = Cine.server_lib('reporting/storage/calculate_account_storage')
EdgecastStream = Cine.server_model('edgecast_stream')
StreamRecordings = Cine.server_model('stream_recordings')

describe 'CalculateAccountStorage', ->

  beforeEach (done)->
    @account = new Account(billingProvider: 'cine.io', name: 'dat account', productPlans: {broadcast: ['basic']})
    @account.save done
  beforeEach (done)->
    @project1 = new Project(name: 'project1', _account: @account._id)
    @project1.save done
  beforeEach (done)->
    @project2 = new Project(name: 'project2', _account: @account._id)
    @project2.save done
  beforeEach (done)->
    @notOwnedProject = new Project(name: 'notOwnedProject')
    @notOwnedProject.save done

  describe 'in mongo', ->
    beforeEach (done)->
      @stream1 = new EdgecastStream(_project: @project1._id, streamName: 'random-1')
      @stream1.save done
    beforeEach (done)->
      @stream2 = new EdgecastStream(_project: @project1._id, streamName: 'random-2')
      @stream2.save done
    beforeEach (done)->
      @stream3 = new EdgecastStream(_project: @project2._id, streamName: 'random-3')
      @stream3.save done
    beforeEach (done)->
      @stream4 = new EdgecastStream(_project: @project2._id, streamName: 'random-4')
      @stream4.save done
    beforeEach (done)->
      @notProjectStream = new EdgecastStream(streamName: 'random-5')
      @notProjectStream.save done

    addRecordings = (recording, thisMonth, lastMonth)->

      recording.recordings.push
        name: "abc"
        size: 3043079
        date: thisMonth

      recording.recordings.push
        name: "def"
        size: 7573983
        date: lastMonth

    createRecordingsForStream = (stream, thisMonth, lastMonth, done)->
      recordings = new StreamRecordings(_edgecastStream: stream)
      addRecordings(recordings, thisMonth, lastMonth)
      recordings.save done

    beforeEach ->
      @thisMonth = new Date
      @lastMonth = new Date
      @lastMonth.setDate(1)
      @lastMonth.setMonth(@lastMonth.getMonth() - 1)
      @twoMonthsAgo = new Date
      @twoMonthsAgo.setDate(1)
      @twoMonthsAgo.setMonth(@twoMonthsAgo.getMonth() - 2)

    beforeEach (done)->
      createRecordingsForStream @stream1, @thisMonth, @lastMonth, done
    beforeEach (done)->
      createRecordingsForStream @stream2, @thisMonth, @lastMonth, done
    beforeEach (done)->
      createRecordingsForStream @stream3, @thisMonth, @lastMonth, done
    beforeEach (done)->
      createRecordingsForStream @stream4, @thisMonth, @lastMonth, done
    beforeEach (done)->
      createRecordingsForStream @notProjectStream, @thisMonth, @lastMonth, done

    describe 'byMonth', ->
      it 'can aggrigate all account projects for a month', (done)->
        CalculateAccountStorage.byMonth @account, @thisMonth, (err, monthlyBytes)->
          expect(err).to.be.undefined
          expect(monthlyBytes).to.equal(42468248)
          done()
      it 'can aggrigate all account projects for a previous month', (done)->
        CalculateAccountStorage.byMonth @account, @lastMonth, (err, monthlyBytes)->
          expect(err).to.be.undefined
          expect(monthlyBytes).to.equal(7573983*4)
          done()

    describe 'total', ->
      it 'can aggrigate all account projects', (done)->
        CalculateAccountStorage.total @account, (err, totalBytes)->
          expect(err).to.be.undefined
          expect(totalBytes).to.equal(42468248)
          done()
