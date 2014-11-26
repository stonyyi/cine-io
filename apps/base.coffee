exports.newApp = (title)->
  app = require('express')()

  # since we're running on heroku which uses nginx
  # http://expressjs.com/guide.html#proxies
  app.enable('trust proxy')

  app.set 'title', title if title

  Cine.middleware 'middleware_base', app
