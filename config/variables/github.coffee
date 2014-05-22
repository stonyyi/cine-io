module.exports =
  clientId: process.env.GITHUB_CLIENT_ID || '0970d704f4137ab1e8a1'
  clientSecret: process.env.GITHUB_CLIENT_SECRET || 'be03b40082e3068f63e1357cda8c9526ff367f57'
  callbackUrl: process.env.GITHUB_CALLBACK_URL || 'http://localtest.me:8181/auth/github/callback'
