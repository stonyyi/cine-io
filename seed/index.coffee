environment = require('../config/environment')
Cine = require '../config/cine'
runNow = !module.parent

ebpabp = Cine.require('seed/ensure_billing_providers_and_billing_plans')

done = (err)->
  if err
    console.log("DONE ERR", err)
    process.exit(1)
  process.exit()

module.exports = (callback)->
  ebpabp(callback)

ebpabp(done) if runNow
