module.exports =
  host: process.env.REDIS_HOST || 'localhost'
  port: process.env.REDIS_PORT || 6379
  db: process.env.REDIS_DB || 2
  pass: process.env.REDIS_PASS || null
