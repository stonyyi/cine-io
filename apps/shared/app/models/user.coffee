Base = Cine.model('base')
_ = require('underscore')

module.exports = class User extends Base
  @id: 'User'
  url: '/user'

  isLoggedIn: ->
    @id?

  @include Cine.lib('date_value')

  createdAt: ->
    @_dateValue('createdAt')

  isNew: ->
    twoMinutesAgo = new Date
    twoMinutesAgo.setMinutes(twoMinutesAgo.getMinutes() - 2)
    @createdAt() > twoMinutesAgo
