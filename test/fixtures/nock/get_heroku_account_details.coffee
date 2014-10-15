response =
  callback_url: "https://api.heroku.com/vendor/apps/app29975387%40heroku.com"
  config:
    CINE_IO_PUBLIC_KEY: "THE PUB KEY"
    CINE_IO_SECRET_KEY: "THE SECRET KEY"
  domains: ["cineio-node-example.herokuapp.com"]
  id: "app29975387@heroku.com"
  name: "cineio-node-example"
  owner_email: "thomas@cine.io"
  region: "amazon-web-services::us-east-1"
  logplex_token: "t.b7b8e1b3-ebd2-4d3a-ae30-614fe9520767"

module.exports = ->
  nock('https://api.heroku.com:443')
    .get('/vendor/apps/app29975387@heroku.com')
    .reply(200, JSON.stringify(response))
