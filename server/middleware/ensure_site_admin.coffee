User = Cine.model('user')
error = new Error("unauthorized")
error.status = 401

module.exports = (req, res, next)->
  return next(error) unless req.currentUser
  currentUser = new User(req.currentUser)
  return next(error) unless currentUser.isPermittedTo('admin', 'site')
  next()
