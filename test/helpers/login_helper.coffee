# usage
# login agent, (err, res)->
# login agent, email, password, (err, res)->
# login agent, User, password, (err, res)->
# login agent, email, password, plan, (err, res)->
# login agent, User, password, plan, (err, res)->
User = Cine.server_model('user')
fakeData = username: "test@dummy.com", password: "spinach", plan: "startup"
module.exports = (agent, email, password, plan, callback)->
  email = email.email if email instanceof User #when email is a user

  if typeof email == 'function'
    callback = email
    params = fakeData

  else if typeof plan == 'function'
    callback = plan
    params = username: email, password: password

  else
    params = username: email, password: password, plan: plan

  agent
    .post('/login')
    .set('X-Requested-With', 'XMLHttpRequest')
    .set('Accept', 'application/json')
    .send(params)
    .expect(200)
    .end (err, res)->
      expect(err).to.be.null
      user = JSON.parse(res.text)
      expect(user.email).to.equal(params.username)
      agent.saveCookies(res)
      process.nextTick ->
        callback(err, res)
