Stream = Cine.model('stream')
Base = Cine.collection('base')

module.exports = class Streams extends Base
  @id: 'Streams'
  model: Stream
  url: '/streams'

  comparator: (model1, model2)->
    assigned1 = model1.assignedAt()
    assigned2 = model2.assignedAt()
    return 0 if assigned1 == assigned2
    if assigned1 > assigned2 then -1 else 1
