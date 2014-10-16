# there is no local equivalent
module.exports =
  ssoSalt: process.env.HEROKU_SSO_SALT || 'fake-ssoSalt'
  username: process.env.HEROKU_USERNAME || 'fake-username'
  password: process.env.HEROKU_PASSWORD || 'fake-password'
