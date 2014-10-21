Project = Cine.server_model('project')
User = Cine.server_model('user')
Account = Cine.server_model('account')
getProject = Cine.server_lib('get_project')

describe 'getProject', ->

  beforeEach (done)->
    @project = new Project(name: 'my project')
    @project.save done

  beforeEach (done)->
    @account = new Account(billingProvider: 'cine.io', name: 'my account', plans: ['free'])
    @account.save done

  beforeEach (done)->
    @user = new User(name: 'the user', email: 'some email')
    @user.save done

  describe 'failure', ->
    it 'errors with requiring an publicKey', (done)->
      getProject {}, requires: 'key', (err, project, options)->
        expect(err).to.equal('public key required')
        expect(project).to.be.null
        expect(options).to.deep.equal(status: 401)
        done()

    it 'errors with requiring an secretKey when necessary', (done)->
      getProject {}, requires: 'secret', (err, project, options)->
        expect(err).to.equal('secret key required')
        expect(project).to.be.null
        expect(options).to.deep.equal(status: 401)
        done()

    it 'errors with requiring an publicKey or secretKey', (done)->
      getProject {}, requires: 'either', (err, project, options)->
        expect(err).to.equal('public key or secret key required')
        expect(project).to.be.null
        expect(options).to.deep.equal(status: 401)
        done()

    describe 'deletedAt', ->
      beforeEach (done)->
        @project.deletedAt = new Date
        @project.save done

      it 'will not find deleted at projects', (done)->
        getProject {publicKey: @project.publicKey}, requires: 'either', (err, project, options)->
          expect(err).to.equal('invalid public key or secret key')
          expect(project).to.be.null
          expect(options).to.deep.equal(status: 401)
          done()

    describe 'throttledAt', ->
      beforeEach (done)->
        @project.throttledAt = new Date
        @project.save done

      it 'will return payment required for throttled at projects', (done)->
        getProject {publicKey: @project.publicKey}, requires: 'either', (err, project, options)->
          expect(err).to.equal('Your account has been disabled. Please update your account.')
          expect(project).to.be.null
          expect(options).to.deep.equal(status: 402)
          done()

  describe 'with user', ->
    it 'will not return a project to a user who does not own that project', (done)->
      getProject {sessionUserId: @user._id.toString(), publicKey: @project.publicKey}, requires: 'secret', userOverride: 'true', (err, project, options)->
        expect(err).to.equal('not permitted')
        expect(project).to.be.null
        expect(options).to.deep.equal(status: 401)
        done()
    describe 'success', ->
      beforeEach (done)->
        @user._accounts.push @account._id
        @user.save done

      beforeEach (done)->
        @project._account = @account._id
        @project.save done

      it 'returns a project based on a logged in user', (done)->
        getProject {sessionUserId: @user._id.toString(), publicKey: @project.publicKey}, requires: 'secret', userOverride: 'true', (err, project, options)=>
          expect(err).to.be.null
          expect(project._id.toString()).to.equal(@project._id.toString())
          expect(options).to.deep.equal(secure: true)
          done()

  describe 'with params', ->
    it 'returns a project based on public key', (done)->
      getProject {publicKey: @project.publicKey}, requires: 'key', (err, project, options)=>
        expect(err).to.be.null
        expect(project._id.toString()).to.equal(@project._id.toString())
        expect(options).to.deep.equal(secure: false)
        done()

    it 'returns a project based on secret key', (done)->
      getProject {secretKey: @project.secretKey}, requires: 'secret', (err, project, options)=>
        expect(err).to.be.null
        expect(project._id.toString()).to.equal(@project._id.toString())
        expect(options).to.deep.equal(secure: true)
        done()

    it 'returns a project based on public key when requesting either', (done)->
      getProject {publicKey: @project.publicKey}, requires: 'either', (err, project, options)=>
        expect(err).to.be.null
        expect(project._id.toString()).to.equal(@project._id.toString())
        expect(options).to.deep.equal(secure: false)
        done()

    it 'returns a project based on secret key when requesting either', (done)->
      getProject {secretKey: @project.secretKey}, requires: 'either', (err, project, options)=>
        expect(err).to.be.null
        expect(project._id.toString()).to.equal(@project._id.toString())
        expect(options).to.deep.equal(secure: true)
        done()
