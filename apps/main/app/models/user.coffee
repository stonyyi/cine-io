Base = Cine.model('base')

module.exports = class User extends Base
  @id: 'User'
  url: '/user'
  @plans: ['free', 'solo', 'startup', 'enterprise']

  isLoggedIn: ->
    @id?

  @include Cine.lib('date_value')

  createdAt: ->
    @_dateValue('createdAt')

  isNew: ->
    thirtySecondsAgo = new Date
    thirtySecondsAgo.setSeconds(thirtySecondsAgo.getSeconds() - 30)
    @createdAt() > thirtySecondsAgo
