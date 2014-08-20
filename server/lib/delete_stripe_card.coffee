_ = require('underscore')

module.exports = (account, cardId, callback)->
  card = _.find account.stripeCustomer.cards, (card)->
    card._id.toString() == cardId.toString()
  return callback("card not found", null) unless card

  card.deletedAt = new Date
  account.save (err)->
    return callback(err, null) if err
    callback(null, account)
