wwwRegexp = /^www/
module.exports = (req, res, next) ->
  isHttps = req.headers["x-forwarded-proto"] == 'https'
  isWww = wwwRegexp.test(req.headers.host)
  return next() if isHttps && isWww
  host = req.headers.host
  host = "www.#{host}" unless isWww
  res.redirect("https://" + host + req.url)
