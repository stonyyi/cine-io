module.exports =
  oauthConsumerKey: process.env.APPDIRECT_OAUTH_CONSUMER_KEY || 'fake-1234'
  oauthConsumerSecret: process.env.APPDIRECT_OAUTH_CONSUMER_SECRET || 'fakeoauthsecret'
  openIdDomain: process.env.APPDIRECT_OPENID_DOMAIN || 'http://localtest.me:8181'
