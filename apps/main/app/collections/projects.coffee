Project = Cine.model('project')
Base = Cine.collection('base')

module.exports = class Projects extends Base
  @id: 'Projects'
  model: Project
  url: '/projects'
