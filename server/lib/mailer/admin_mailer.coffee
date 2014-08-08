sendTemplateEmail = Cine.server_lib('mailer/send_template_email')
_ = require('underscore')
util = require('util')
noop = ->

exports.cardAdded = (user, callback=noop)->
  options =
    email: user.email
    _id: user._id
    plan: user.plan
  mailOptions =
    subject: '[KPI] Credit Card added'
    content: """
    <p>A user added a credit card!</p>
    <p><pre>#{util.inspect(options)}</pre></p>
    """
  sendAdminEmail mailOptions, callback

exports.newUser = (user, context, callback=noop)->
  mailOptions =
    subject: '[KPI] New User'
    content: """
    <p>A new user just signed up!</p>
    <p>Context: #{context}!</p>
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
