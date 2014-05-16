module.exports = process.env.MONGOHQ_URL || "mongodb://localhost/#{if process.env.NODE_ENV == 'test' then 'cineio-test' else 'cineio-development' }"
