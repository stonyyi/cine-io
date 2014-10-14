User = Cine.server_model('user')
Account = Cine.server_model('account')
_ = require('underscore')
async = require('async')

fullCurrentUserJson = (user, callback)->
  userJSON = user.simpleCurrentUserJSON()
  return callback(null, userJSON) if _.isEmpty(userJSON._accounts)
  query =
    _id:
      $in: userJSON._accounts
    deletedAt:
      $exists: false

  Account.find query, (err, accounts)->
    return callback(err, userJSON) if err
    async.map accounts, fullCurrentUserJson.accountJson, (err, accountsJson)->
      userJSON.accounts = accountsJson
      delete userJSON._accounts
      callback(null, userJSON)

fullCurrentUserJson.accountJson = (account, callback)->
  returnJson =
    id: account._id
    name: account.name
    herokuId: account.herokuId
    masterKey: account.masterKey
    plans: account.plans
    provider: account.billingProvider
    email: account.billingEmail
  stripeCards = []
  _.each account.stripeCustomer.cards, (card)->
    return if card.deletedAt?
    newCard = _.pick(card, 'last4', 'brand', 'exp_month', 'exp_year')
    newCard.id = card._id
    stripeCards.push(newCard)
  returnJson.stripeCard = stripeCards[0]
  if account.billingProvider == 'appdirect'
    returnJson.appdirect =
      baseUrl: account.appdirectData.marketplace.baseUrl

  callback(null, returnJson)

module.exports = fullCurrentUserJson
