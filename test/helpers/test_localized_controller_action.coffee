module.exports = (Controller)->
  return (action, params, callback)->
    Controller[action].call(Controller, params, callback)
