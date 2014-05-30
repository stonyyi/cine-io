Base = Cine.model('base')

module.exports = class Stream extends Base
  @id: 'Stream'
  url: '/stream?id=:id&secretKey=:secretKey'

  @include Cine.lib('date_value')

  assignedAt: ->
    @_dateValue('assignedAt')
