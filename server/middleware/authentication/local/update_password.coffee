User = Cine.server_model('user')
PasswordChangeRequest = Cine.server_model 'password_change_request'
createNewToken = Cine.middleware('authentication/remember_me').createNewToken

module.exports = (app)->
  app.post '/update-password', (req, res)->
    return res.status(400).send("missing identifier") unless req.body.identifier
    return res.status(400).send("missing password") unless req.body.password

    PasswordChangeRequest.findOne identifier: req.body.identifier, (err, pcr)->
      return res.status(400).send(err || 'token not found') if err || !pcr

      User.findById pcr._user, (err, user)->
        return res.status(400).send(err || 'invalid token') if err || !user

        user.assignHashedPasswordAndSalt req.body.password, (err)->
          return res.status(400).send(null) if err

          user.save (err)->
            return res.status(400).send(null) if err
            req.login user, (err)->
              return res.status(400).send(null) if err
              createNewToken user, (err, token)->
                res.cookie('remember_me', token, maxAge: createNewToken.oneYear, httpOnly: true)
                return res.send(redirect: '/')
