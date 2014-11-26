console.debug('loading main/app/router.coffee')
window.Cine = require 'cine' if typeof window != 'undefined'
module.exports = Cine.arch('shared_app')
