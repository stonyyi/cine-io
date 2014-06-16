sendTemplateEmail = Cine.server_lib('mailer/send_template_email')
_ = require('underscore')
util = require('util')
noop = ->

exports.newUser = (user, callback=noop)->
  mailOptions =
    subject: '[KPI] New User'
    content: """
    <p>A new user just signed up!</p>
    <p><pre>#{util.inspect(user)}</pre></p>
    """
  sendAdminEmail mailOptions, callback

sendAdminEmail = (mailOptions, callback)->
  throw new Error('no subject') unless mailOptions.subject
  throw new Error('no content') unless mailOptions.content
  return callback() if process.env.NODE_ENV == 'development'
  _.defaults mailOptions,
    templateName: 'admin-just-content'
    toEmail: 'accounts@cine.io'
    toName: 'cine.io'
    images: []

  mailOptions.userTemplateVars =
    content: mailOptions.content
  delete mailOptions.content

  sendTemplateEmail.send mailOptions, callback
