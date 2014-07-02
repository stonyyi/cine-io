PermissionManager = Cine.lib('permission_manager')
ProjectBackbone = Cine.model('project')
ProjectMongoose = Cine.server_model('project')

describe 'PermissionManager', ->
  describe '#clearPermissions', ->
    it 'can clear permissions', ->
      p = new PermissionManager('abc')
      expect(p.permissions).to.equal('abc')
      p.clearPermissions()
      expect(p.permissions).to.be.null
  describe '#setPermissions', ->
    it 'can set permissions', ->
      p = new PermissionManager('abc')
      expect(p.permissions).to.equal('abc')
      p.setPermissions('new permissions')
      expect(p.permissions).to.equal('new permissions')
  describe '#addPermission', ->
    it 'can add permissions', ->
      p = new PermissionManager(['abc'])
      expect(p.permissions).to.deep.equal(['abc'])
      p.addPermission('name', 'the id')
      expect(p.permissions).to.deep.equal(['abc', {objectName: 'name', objectId: 'the id'}])

  describe '#check', ->
    beforeEach ->
      @p = new PermissionManager([])

    it 'requires a verb and an object', ->
      expect(@p.check()).to.be.false
      expect(@p.check('a')).to.be.false

    it 'requires permissions', ->
      expect(@p.check('a', 'b')).to.be.false

    it 'short circuits if the user is an admin of the site', ->
      @p.addPermission('site', 'admin')
      expect(@p.check('a', 'b')).to.be.true

    it 'cannot test against a string', ->
      @p.addPermission('some', 'thing')
      expect(@p.check('some', 'thing')).to.be.false

    it 'can check Mongoose documents', ->
      model = new ProjectMongoose
      @p.addPermission('Project', model._id)
      expect(@p.check('edit', model)).to.be.true

    it 'can check Backbone models', ->
      model = new ProjectBackbone(id: 'the id')
      @p.addPermission('Project', model.id)
      expect(@p.check('edit', model)).to.be.true

    it 'can check objects', ->
      model = {objectName: 'WhoHoo', objectId: '123'}
      @p.addPermission('WhoHoo', model.objectId)
      expect(@p.check('edit', model)).to.be.true

    it 'defaults to false', ->
      model = new ProjectBackbone(id: 'the id')
      expect(@p.check('edit', model)).to.be.false
