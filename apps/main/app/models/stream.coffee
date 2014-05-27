Base = Cine.model('base')

module.exports = class Stream extends Base
  @id: 'Stream'
  url: '/stream?id=:id&apiSecret=:apiSecret'
