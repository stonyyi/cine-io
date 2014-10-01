module.exports =
  host: process.env.REDIS_HOST || 'localhost'
  port: process.env.REDIS_PORT || 6379
  pass: process.env.REDIS_PASS || null


# if running locally use the second db
# the reason is that in test we clear redis and it's annoying to clear dev redis when the tests run
# this way we do not have differences in CI and prod, the only difference is dev
if process.env.NODE_ENV == 'development'
  module.exports.db = 2
