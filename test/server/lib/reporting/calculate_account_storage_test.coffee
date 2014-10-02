Account = Cine.server_model('account')
Project = Cine.server_model('project')
CalculateAccountStorage = Cine.server_lib('reporting/calculate_account_storage')
CalculateProjectStorageOnEdgecast = Cine.server_lib('reporting/calculate_project_storage_on_edgecast')
EdgecastStream = Cine.server_model('edgecast_stream')
EdgecastRecordings = Cine.server_model('edgecast_recordings')

describe 'CalculateAccountStorage', ->

  beforeEach (done)->
    @account = new Account(name: 'dat account', plans: ['basic'])
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

  describe 'onEdgecast', ->

    beforeEach ->
      @storageStub = sinon.stub CalculateProjectStorageOnEdgecast, 'total', (project, callback)=>

        result = switch project._id.toString()
          when @project1._id.toString() then 111
          when @project2._id.toString() then 222
          when @notOwnedProject._id.toString() then 444
          else 888
        callback null, result

    afterEach ->
      @storageStub.restore()

    it "calculates the storage over all of the account's projects", (done)->
      CalculateAccountStorage.onEdgecast @account, (err, totalInBytes)->
        expect(err).to.be.undefined
        expect(totalInBytes).to.equal(333)
        done()

  describe 'total', ->
    beforeEach (done)->
      @stream1 = new EdgecastStream(_project: @project1._id)
      @stream1.save done
    beforeEach (done)->
      @stream2 = new EdgecastStream(_project: @project1._id)
      @stream2.save done
    beforeEach (done)->
      @stream3 = new EdgecastStream(_project: @project2._id)
      @stream3.save done
    beforeEach (done)->
      @stream4 = new EdgecastStream(_project: @project2._id)
      @stream4.save done
    beforeEach (done)->
      @notProjectStream = new EdgecastStream()
      @notProjectStream.save done

    addRecordings = (recording)->

      recording.recordings.push
        name: "abc"
        size: 3043079
        date: new Date

      recording.recordings.push
        name: "def"
        size: 7573983
        date: new Date

    createRecordingsForStream = (stream, done)->
      recordings = new EdgecastRecordings(_edgecastStream: stream)
      addRecordings(recordings)
      recordings.save done

    beforeEach (done)->
      createRecordingsForStream @stream1, done
    beforeEach (done)->
      createRecordingsForStream @stream2, done
    beforeEach (done)->
      createRecordingsForStream @stream3, done
    beforeEach (done)->
      createRecordingsForStream @stream4, done
    beforeEach (done)->
      createRecordingsForStream @notProjectStream, done

    it 'can aggrigate all account projects', (done)->
      CalculateAccountStorage.total @account, (err, monthlyBytes)->
        expect(err).to.be.undefined
        expect(monthlyBytes).to.equal(42468248)
        done()
