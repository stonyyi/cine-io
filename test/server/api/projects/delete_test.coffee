Project = Cine.server_model('project')
Delete = testApi Cine.api('projects/delete')

describe 'Projects#Delete', ->
  testApi.requresApiKey Delete, 'secret'

  beforeEach (done)->
    @project = new Project(name: 'my project', streamsCount: 1)
    @project.save done

  it 'adds deletedAt to the project', (done)->
    params = secretKey: @project.secretKey
    Delete params, (err, response, options)=>
      expect(err).to.be.null
      expect(response.id).to.equal(@project._id.toString())
      expect(response.deletedAt).to.be.instanceOf(Date)
      Project.findById @project._id, (err, project)->
        expect(project.deletedAt).to.be.instanceOf(Date)
        done()
