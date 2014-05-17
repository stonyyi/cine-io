Base = Cine.model('base')

module.exports = class User extends Base
  @id: 'User'
  url: '/user'
  idAttribute: '_id'

  isLoggedIn: ->
    @id?
