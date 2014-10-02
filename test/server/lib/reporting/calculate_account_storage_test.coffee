Account = Cine.server_model('account')
Project = Cine.server_model('project')
CalculateAccountStorage = Cine.server_lib('reporting/calculate_account_storage')
CalculateProjectStorageOnEdgecast = Cine.server_lib('reporting/calculate_project_storage_on_edgecast')


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

  describe 'onEdgecast', ->

    it "calculates the storage over all of the account's projects", (done)->
      CalculateAccountStorage.onEdgecast @account, (err, totalInBytes)->
        expect(err).to.be.undefined
        expect(totalInBytes).to.equal(333)
        done()
