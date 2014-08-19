error = new Error("unauthorized")
error.status = 401

module.exports = (req, res, next)->
  return next(error) unless req.currentUser
  return next(error) unless req.currentUser.isSiteAdmin
  next()
