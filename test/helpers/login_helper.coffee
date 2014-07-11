module.exports = (agent, user, password, callback)->
  agent
    .post('/login')
    .set('X-Requested-With', 'XMLHttpRequest')
    .send(username: user.email, password: password)
    .expect(200)
    .end (err, res)->
      expect(err).to.be.null
      agent.saveCookies(res)
      process.nextTick ->
        callback(err, res)
