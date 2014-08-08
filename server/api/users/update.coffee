User = Cine.server_model('user')
_str = require 'underscore.string'
TextMongooseErrorMessage = Cine.server_lib('text_mongoose_error_message')
mailer = Cine.server_lib('mailer')
addStripeCardToUser = Cine.server_lib("add_stripe_card_to_user")
deleteStripeCard = Cine.server_lib("delete_stripe_card")

updateUser = (params, callback)->
  return callback("not logged in", null, status: 401) unless params.sessionUserId
  return callback("id required", null, status: 400) unless params.id
  # can update user if the user is the logged in user
  return updateUser.doUpdate(params, callback) if params.sessionUserId.toString() == params.id.toString()
  # otherwise check for site admin privleges
  return callback("unauthorized", null, status: 401)
  throw new Error("site admin not implemented yet")

updateUser.doUpdate = (params, callback)->
  User.findById params.id, (err, user)->
    return callback(err, null, status: 400) if err
    return callback("not found", null, status: 404) unless user

    if params.stripeToken
      return addStripeCardToUser user, params.stripeToken, (err, user)->
        return callback(TextMongooseErrorMessage(err), null, status: 400) if err
        mailer.admin.cardAdded(user)
        callback(null, user.simpleCurrentUserJSON())

    if params.deleteCard
      return deleteStripeCard user, params.deleteCard, (err, user)->
        return callback(TextMongooseErrorMessage(err), null, status: 400) if err
        callback(null, user.simpleCurrentUserJSON())

    user.name = params.name unless _str.isBlank(params.name)
    user.email = params.email unless _str.isBlank(params.email)
    user.plan = params.plan unless _str.isBlank(params.plan)
    user.save (err)->
      return callback(TextMongooseErrorMessage(err), null, status: 400) if err
      if params.completedsignup
        mailer.welcomeEmail(user)
        mailer.admin.newUser(user, params.completedsignup)
      callback(null, user.simpleCurrentUserJSON())

module.exports = updateUser
