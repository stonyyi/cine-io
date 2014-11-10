User = Cine.server_model('user')

error = new Error("unauthorized")
error.status = 401

module.exports = (req, res, next)->
  if req.xhr
    return next(error) unless req.user
    User.findById req.user, (err, user)->
      return next(error) if err || !user || !user.isSiteAdmin
      next()
  else
    return next(error) unless req.currentUser
    return next(error) unless req.currentUser.isSiteAdmin
    next()
