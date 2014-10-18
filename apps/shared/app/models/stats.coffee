Base = Cine.model('base')
_ = require('underscore')


module.exports = class Stats extends Base
  @id: 'Stats'
  url: '/stats?id=:id'
  idAttribute: 'id'

  getAccounts: (monthKey)->
    usage = @get('usage')
    # hack for now
    # eventually use monthKey
    accounts = _.values(usage)[0]

  # return an array of accounts sorted by usage
  getSortedUsage: (type, monthKey)->
    accounts = @getAccounts(monthKey)
    usageSort = (attributes)->
      attributes.usage[type] * -1

    makeAccount = (attributes)=>
      new Account attributes, app: @app

    _.chain(accounts).sortBy(usageSort).map(makeAccount).value()

  total: (type, monthKey)->
    accounts = @getAccounts(monthKey)

    addUsage = (accum, item)->
      accum + item.usage[type]

    _.inject accounts, addUsage, 0

Accounts = Cine.collection('accounts')
Account = Cine.model('account')
