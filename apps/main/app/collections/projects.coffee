Project = Cine.model('project')
Base = Cine.collection('base')

module.exports = class Projects extends Base
  @id: 'Projects'
  model: Project
  url: '/projects'

  comparator: (model1, model2)->
    updated1 = model1.updatedAt()
    updated2 = model2.updatedAt()
    return 0 if updated1 == updated2
    if updated1 > updated2 then -1 else 1
