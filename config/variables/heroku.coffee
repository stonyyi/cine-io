# there is no local equivalent
module.exports =
  ssoSalt: process.env.HEROKU_SSO_SALT || 'fake-ssoSalt'
  username: process.env.HEROKU_USERNAME || 'fake-username'
  password: process.env.HEROKU_PASSWORD || 'fake-password'
  accessKey: "e090c3bd-b4ed-4177-8df3-08d6c2cf93e2"
