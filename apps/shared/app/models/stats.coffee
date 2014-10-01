Base = Cine.model('base')
_ = require('underscore')
isServer = typeof window is 'undefined'

usageSort = (attributes)->
  attributes.usage * -1

module.exports = class Stats extends Base
  @id: 'Stats'
  url: if isServer then '/stats?id=:id' else '/stats'
  idAttribute: 'id'

  # return an array of accounts sorted by usage
  getSortedUsage: ->
    usage = @get('usage')
    makeAccount = (attributes)=>
      new Account attributes, app: @app
    _.chain(usage).sortBy(usageSort).map(makeAccount).value()

Accounts = Cine.collection('accounts')
Account = Cine.model('account')
