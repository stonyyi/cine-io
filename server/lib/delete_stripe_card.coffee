_ = require('underscore')

module.exports = (user, cardId, callback)->
  card = _.find user.stripeCustomer.cards, (card)->
    card._id.toString() == cardId.toString()
  return callback("card not found", null) unless card

  card.deletedAt = new Date
  user.save (err)->
    return callback(err, null) if err
    callback(null, user)
