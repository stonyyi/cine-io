Project = Cine.server_model('project')
Update = testApi Cine.api('projects/update')

describe 'Projects#Update', ->
  testApi.requresApiKey Update, 'secret'

  beforeEach (done)->
    @project = new Project(name: 'my project', streamsCount: 1)
    @project.save done

  it 'changes the name to the project', (done)->
    params = secretKey: @project.secretKey, name: 'new name'
    Update params, (err, response, options)=>
      expect(err).to.be.null
      expect(response.id).to.equal(@project._id.toString())
      expect(response.name).to.equal('new name')
      Project.findById @project._id, (err, project)->
        expect(project.name).to.equal('new name')
        done()
