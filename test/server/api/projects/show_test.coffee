Project = Cine.server_model('project')
ProjectsShow = Cine.api('projects/show')
Show = testApi ProjectsShow

describe 'Projects#Show', ->
  testApi.requresApiKey Show, 'secret'

  beforeEach (done)->
    @project = new Project(name: 'my project', streamsCount: 1)
    @project.save done

  it 'returns an project', (done)->
    params = secretKey: @project.secretKey
    Show params, (err, response, options)=>
      expect(err).to.be.null
      expect(response.id).to.equal(@project._id.toString())
      expect(response.name).to.equal('my project')
      expect(response.streamsCount).to.equal(1)
      expect(response.secretKey).to.equal(@project.secretKey)
      expect(response.updatedAt).to.be.instanceOf(Date)
      done()

  describe 'ProjectsShow#toJSON', ->
    it 'returns deletedAt', (done)->
      ProjectsShow.toJSON @project, (err, project)=>
        expect(err).to.be.null
        expect(project.deletedAt).to.be.undefined
        @project.deletedAt = new Date
        ProjectsShow.toJSON @project, (err, project)->
          expect(err).to.be.null
          expect(project.deletedAt).to.be.instanceOf(Date)
          done()
