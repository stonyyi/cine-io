Account = Cine.model('account')
Base = Cine.collection('base')

module.exports = class Accounts extends Base
  @id: 'Accounts'
  model: Account
  url: '/projects'

  comparator: (model1, model2)->
    created1 = model1.createdAt()
    created2 = model2.createdAt()
    return 0 if created1 == created2
    if created1 > created2 then -1 else 1
