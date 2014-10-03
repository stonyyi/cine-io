Base = Cine.model('base')
_ = require('underscore')


module.exports = class Stats extends Base
  @id: 'Stats'
  url: '/stats?id=:id'
  idAttribute: 'id'

  # return an array of accounts sorted by usage
  getSortedUsage: (type)->
    accounts = @get('usage')

    usageSort = (attributes)->
      attributes.usage[type] * -1

    makeAccount = (attributes)=>
      new Account attributes, app: @app

    _.chain(accounts).sortBy(usageSort).map(makeAccount).value()

  total: (type)->
    accounts = @get('usage')

    addUsage = (accum, item)->
      accum + item.usage[type]

    _.inject accounts, addUsage, 0

Accounts = Cine.collection('accounts')
Account = Cine.model('account')
