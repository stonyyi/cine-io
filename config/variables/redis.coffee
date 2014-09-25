module.exports =
  host: process.env.REDIS_HOST || 'localhost'
  port: process.env.REDIS_PORT || 6379
  pass: process.env.REDIS_PASS || null
