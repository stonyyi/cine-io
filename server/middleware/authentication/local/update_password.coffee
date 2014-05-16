User = Cine.server_model('user')
PasswordChangeRequest = Cine.server_model 'password_change_request'
createNewToken = Cine.middleware('authentication/remember_me').createNewToken

module.exports = (app)->
  app.post '/update-password', (req, res)->
    return res.send(400, "missing identifier") unless req.body.identifier
    return res.send(400, "missing password") unless req.body.password

    PasswordChangeRequest.findOne identifier: req.body.identifier, (err, pcr)->
      return res.send(400, err || 'token not found') if err || !pcr

      User.findById pcr._user, (err, user)->
        return res.send(400, err || 'invalid token') if err || !user

        user.assignHashedPasswordAndSalt req.body.password, (err)->
          return res.send(400, null) if err

          user.save (err)->
            return res.send(400, null) if err
            req.login user, (err)->
              return res.send(400, null) if err
              createNewToken user, (err, token)->
                res.cookie('remember_me', token, maxAge: createNewToken.oneYear, httpOnly: true)
                return res.send(redirect: '/')
