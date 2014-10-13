sendTemplateEmail = Cine.server_lib('mailer/send_template_email')
_ = require('underscore')
util = require('util')
noop = ->

exports.cardAdded = (account, callback=noop)->
  options =
    billingEmail: account.billingEmail
    _id: account._id
    plans: account.plans
  mailOptions =
    subject: '[KPI] Credit Card added'
    content: """
    <p>An account added a credit card!</p>
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


exports.cardDeclined = (account, abh, now, callback=noop)->
  mailOptions =
    subject: 'Card Declined'
    content: """
      <p>Card was declined!</p>
      <p><pre>#{now}</pre></p>
      <p><pre>#{util.inspect(account)}</pre></p>
      <p><pre>#{util.inspect(abh)}</pre></p>
    """
  sendAdminEmail mailOptions, callback

exports.unknownChargeError = (account, abh, now, callback=noop)->
  mailOptions =
    subject: 'Unknown charge error'
    content: """
      <p>Unknown charge error!</p>
      <p><pre>#{now}</pre></p>
      <p><pre>#{util.inspect(account)}</pre></p>
      <p><pre>#{util.inspect(abh)}</pre></p>
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
