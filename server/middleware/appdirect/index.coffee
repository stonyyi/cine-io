module.exports = (app)->
  Cine.middleware('appdirect/login', app)
  Cine.middleware('appdirect/subscription/create', app)
  Cine.middleware('appdirect/subscription/cancel', app)
  Cine.middleware('appdirect/subscription/notice', app)
  Cine.middleware('appdirect/users/assign', app)
  Cine.middleware('appdirect/users/unassign', app)
  Cine.middleware('appdirect/addons', app)
