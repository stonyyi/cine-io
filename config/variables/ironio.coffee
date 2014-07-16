fs = require 'fs'
config = "#{Cine.root}/worker/iron.json"

module.exports = JSON.parse(fs.readFileSync(config, 'utf8'))
