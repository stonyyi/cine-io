Project = Cine.server_model('project')
getProject = Cine.server_lib('get_project')

describe 'getProject', ->

  beforeEach (done)->
    @project = new Project(name: 'my project', plan: 'free')
    @project.save done

  it 'errors with requiring an apiKey', (done)->
    getProject {}, requires: 'key', (err, project, options)->
      expect(err).to.equal('api key required')
      expect(project).to.be.null
      expect(options).to.deep.equal(status: 401)
      done()

  it 'errors with requiring an apiSecret when necessary', (done)->
    getProject {}, requires: 'secret', (err, project, options)->
      expect(err).to.equal('api secret required')
      expect(project).to.be.null
      expect(options).to.deep.equal(status: 401)
      done()

  it 'errors with requiring an apiKey or apiSecret', (done)->
    getProject {}, requires: 'either', (err, project, options)->
      expect(err).to.equal('api key or api secret required')
      expect(project).to.be.null
      expect(options).to.deep.equal(status: 401)
      done()

  it 'returns a project based on api key', (done)->
    getProject {apiKey: @project.apiKey}, requires: 'key', (err, project, options)=>
      expect(err).to.be.null
      expect(project._id.toString()).to.equal(@project._id.toString())
      expect(options).to.deep.equal(secure: false)
      done()

  it 'returns a project based on api secret', (done)->
    getProject {apiSecret: @project.apiSecret}, requires: 'secret', (err, project, options)=>
      expect(err).to.be.null
      expect(project._id.toString()).to.equal(@project._id.toString())
      expect(options).to.deep.equal(secure: true)
      done()

  it 'returns a project based on api key when requesting either', (done)->
    getProject {apiKey: @project.apiKey}, requires: 'either', (err, project, options)=>
      expect(err).to.be.null
      expect(project._id.toString()).to.equal(@project._id.toString())
      expect(options).to.deep.equal(secure: false)
      done()

  it 'returns a project based on api secret when requesting either', (done)->
    getProject {apiSecret: @project.apiSecret}, requires: 'either', (err, project, options)=>
      expect(err).to.be.null
      expect(project._id.toString()).to.equal(@project._id.toString())
      expect(options).to.deep.equal(secure: true)
      done()
