Stream = Cine.model('stream')
Base = Cine.collection('base')

module.exports = class Streams extends Base
  @id: 'Streams'
  model: Stream
  url: '/streams'
