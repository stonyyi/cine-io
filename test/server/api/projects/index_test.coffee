Project = Cine.server_model('project')
User = Cine.server_model('user')
Index = testApi Cine.api('projects/index')

describe 'Projects#Index', ->
  testApi.requresLoggedIn Index

  beforeEach (done)->
    @project1 = new Project(name: 'my project1', createdAt: new Date, plan: 'free')
    @project1.save done

  beforeEach (done)->
    twoDaysAgo = new Date
    twoDaysAgo.setDate(twoDaysAgo.getDate() - 2)
    @project2 = new Project(name: 'my project2', createAt: twoDaysAgo, plan: 'free')
    @project2.save done

  beforeEach (done)->
    @notMyProject = new Project(name: 'not my project', plan: 'free')
    @notMyProject.save done

  beforeEach (done)->
    @user = new User(name: 'me', email: 'my email')
    @user.permissions.push objectId: @project1._id, objectName: "Project"
    @user.permissions.push objectId: @project2._id, objectName: "Project"
    @user.save done

  it 'returns the projects', (done)->
    Index {}, user: @user, (err, response, options)=>
      expect(err).to.be.undefined
      expect(response).to.have.length(2)
      expect(response[0].id).to.equal(@project2._id.toString())
      expect(response[1].id).to.equal(@project1._id.toString())
      expect(response[0].name).to.equal('my project2')
      expect(response[1].name).to.equal('my project1')
      done()
