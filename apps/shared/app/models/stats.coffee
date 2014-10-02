Base = Cine.model('base')
_ = require('underscore')


module.exports = class Stats extends Base
  @id: 'Stats'
  url: '/stats?id=:id'
  idAttribute: 'id'

  # return an array of accounts sorted by usage
  getSortedUsage: (type)->
    usage = @get('usage')

    usageSort = (attributes)->
      attributes.usage[type] * -1

    makeAccount = (attributes)=>
      new Account attributes, app: @app

    _.chain(usage).sortBy(usageSort).map(makeAccount).value()

Accounts = Cine.collection('accounts')
Account = Cine.model('account')
