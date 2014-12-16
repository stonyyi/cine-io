Project = Cine.server_model('project')
Account = Cine.server_model('account')
Index = testApi Cine.api('projects/index')

describe 'Projects#Index', ->
  testApi.requiresMasterKey Index

  beforeEach (done)->
    @account = new Account(billingProvider: 'cine.io', name: 'an account', productPlans: {broadcast: ['free']}, masterKey: 'the acc master')
    @account.save done

  beforeEach (done)->
    @project1 = new Project(name: 'my project1', createdAt: new Date, _account: @account._id)
    @project1.save done

  beforeEach (done)->
    twoDaysAgo = new Date
    twoDaysAgo.setDate(twoDaysAgo.getDate() - 2)
    @project2 = new Project(name: 'my project2', createdAt: twoDaysAgo, _account: @account._id)
    @project2.save done

  beforeEach (done)->
    @deletedAtProject = new Project(name: 'my deletedAtProject', deletedAt: new Date, _account: @account._id)
    @deletedAtProject.save done

  beforeEach (done)->
    @notMyProject = new Project(name: 'not my project')
    @notMyProject.save done

  it 'returns the projects', (done)->
    Index {masterKey: 'the acc master'}, (err, response, options)=>
      expect(err).to.be.undefined
      expect(response).to.have.length(2)
      expect(response[0].id).to.equal(@project2._id.toString())
      expect(response[1].id).to.equal(@project1._id.toString())
      expect(response[0].name).to.equal('my project2')
      expect(response[1].name).to.equal('my project1')
      done()
