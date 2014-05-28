Base = Cine.model('base')
isServer = typeof window is 'undefined'

module.exports = class Project extends Base
  @id: 'Project'
  url: if isServer then "/project?publicKey=:publicKey" else "/project"
