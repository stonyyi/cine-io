Project = Cine.server_model('project')
Show = testApi Cine.api('projects/show')

describe 'Projects#Show', ->
  testApi.requresApiKey Show, 'secret'

  beforeEach (done)->
    @project = new Project(name: 'my project', plan: 'free', streamsCount: 1)
    @project.save done

  it 'returns an project', (done)->
    params = secretKey: @project.secretKey
    Show params, (err, response, options)=>
      expect(err).to.be.null
      expect(response.id).to.equal(@project._id.toString())
      expect(response.name).to.equal('my project')
      expect(response.plan).to.equal('free')
      expect(response.streamsCount).to.equal(1)
      expect(response.secretKey).to.equal(@project.secretKey)
      done()
