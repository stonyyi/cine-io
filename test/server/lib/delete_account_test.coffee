async = require('async')
deleteAccount = Cine.server_lib('delete_account')
Account = Cine.server_model('account')
Project = Cine.server_model('project')
EdgecastStream = Cine.server_model('edgecast_stream')

describe 'deleteAccount', ->

  beforeEach (done)->
    @account = new Account(tempPlan: 'test')
    @account.save done

  beforeEach (done)->
    @ownedProject1 = new Project(name: "in test project", _account: @account._id)
    @ownedProject1.save done

  beforeEach (done)->
    @stream1 = new EdgecastStream(streamName: 'project1 stream', _project: @ownedProject1)
    @stream1.save done

  beforeEach (done)->
    @stream2 = new EdgecastStream(streamName: 'project1 stream2', _project: @ownedProject1)
    @stream2.save done

  beforeEach (done)->
    @ownedProject2 = new Project(name: "in test project2", _account: @account._id)
    @ownedProject2.save done

  beforeEach (done)->
    @stream3 = new EdgecastStream(streamName: 'project2 stream', _project: @ownedProject2)
    @stream3.save done

  beforeEach (done)->
    @notOwnedProject = new Project(name: "in test project3")
    @notOwnedProject.save done

  beforeEach (done)->
    @stream4 = new EdgecastStream(streamName: 'notOwnedProject stream', _project: @notOwnedProject)
    @stream4.save done

  beforeEach (done)->
    @noProjectStream = new EdgecastStream(streamName: 'not owned')
    @noProjectStream.save done

  beforeEach (done)->
    deleteAccount @account, done

  it "adds deletedAt to a account", (done)->
    Account.findById @account._id, (err, account)->
      expect(err).to.be.null
      expect(account.deletedAt).to.be.instanceOf(Date)
      done()

  it "deletes the projects", (done)->
    Project.find _id: {$in: [@ownedProject1._id, @ownedProject2._id]}, (err, projects)=>
      expect(err).to.be.null
      expect(projects[0].deletedAt).to.be.instanceOf(Date)
      expect(projects[1].deletedAt).to.be.instanceOf(Date)
      Project.findById @notOwnedProject, (err, project)->
        expect(err).to.be.null
        expect(project.deletedAt).to.be.undefined
        done()

  it "deletes the streams", (done)->
    EdgecastStream.find _id: {$in: [@stream1._id, @stream2._id, @stream3._id]}, (err, streams)=>
      expect(err).to.be.null
      expect(streams[0].deletedAt).to.be.instanceOf(Date)
      expect(streams[1].deletedAt).to.be.instanceOf(Date)
      expect(streams[2].deletedAt).to.be.instanceOf(Date)
      EdgecastStream.find _id: {$in: [@stream4._id, @noProjectStream._id]}, (err, notDeletedStreams)->
        expect(err).to.be.null
        expect(notDeletedStreams[0].deletedAt).to.be.undefined
        expect(notDeletedStreams[1].deletedAt).to.be.undefined
        done()
