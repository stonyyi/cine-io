URL = require('url')
forceHttpsAndWww = Cine.middleware('force_https_and_www')
_ = require 'underscore'

describe 'forceHttpsAndWww', ->
  test = (input, expected, done)->
    url = URL.parse(input)
    req =
      url: url.path
      headers:
        'x-forwarded-proto': url.protocol
        host: url.host
    res =
      redirect: (path)->
        expect(path).to.equal(expected)
        done()
    next = done
    forceHttpsAndWww(req, res, next)

  prefixes = ["http://www.", "http://", "https://", "https://www."]
  _.each prefixes, (prefix)->
    url = "#{prefix}hey.com"
    finalUrl = 'https://www.hey.com/'
    it "redirects #{url} to #{finalUrl}", (done)->
      test(url, finalUrl, done)

    pathUrl = "#{url}/ab/cd"
    finalPathUrl = "#{finalUrl}ab/cd"
    it "redirects #{pathUrl} to #{finalPathUrl}", (done)->
      test(pathUrl, finalPathUrl, done)
