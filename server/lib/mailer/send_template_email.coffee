_ = require('underscore')
_.str = require('underscore.string')
templateMailer = Cine.server_lib('mailer/mandrill_template_mailer')
noop = ->

# Essentially calls sendBatch with a single user
# takes a single to field (toName, toEmail) and
# also takes userTemplateVars instead of the mandrill mergeVars [{},{},…] user style
#
# send - send a templated email to a single individual
#   options:
#     templateName: 'donated_for_ticket'
#     subject: 'Your ticket to ARTIST LIVE'
#     fromEmail: 'support@cine.io'
#     fromName: 'cine.io'
#     toEmail: 'johndoe@example.com'
#     toName: 'John Doe'
#     userTemplateVars: {
#       name: 'John Doe'
#       first_name: 'John'
#       ...
#     }
#     images: [
#       { type: "image/png", name: "LOGO_IMAGE", content: 'BASE64_ENCODED_IMAGE_DATA' }
#       { type: "image/jpeg", name: "EVENT_IMAGE", content: 'BASE64_ENCODED_IMAGE_DATA' }
#     ]
#
#   callback: function with 2 arguments (error, message)
module.exports.send = (options, callback)->
  options.to = [ { name: options.toName, email: options.toEmail, type: 'to' } ]
  options.mergeVars = [ {
    rcpt: options.toEmail
    templateVars: options.userTemplateVars
  } ]

  delete options.toEmail
  delete options.toName
  delete options.templateVars
  module.exports.sendBatch options, callback


# sendBatch
#   templateName: 'donated_for_ticket'
#   subject: 'Your ticket to ARTIST LIVE'
#   fromEmail: 'support@cine.io'
#   fromName: 'cine.io'
#   globalTemplateVars:
#     event_title: 'Cyclone Phalin Relief Show'
#     artist: 'Sean Hayes'
#     ...
#   attachments: [
#     {
#       type: "text/calendar"
#       name: "#{event.title}.ics"
#       content: new Buffer(generateEventIcs(event)).toString('base64')
#     }
#     ...
#   ]
#   images: [
#     { type: "image/png", name: "LOGO_IMAGE", content: 'BASE64_ENCODED_IMAGE_DATA' }
#     { type: "image/png", name: "EVENT_IMAGE", content: 'BASE64_ENCODED_IMAGE_DATA' }
#     ...
#   ]
#   to: [
#     { email: 'jeffrey@givingstage.com', name: 'Jeffrey Wescott', type: 'to' }
#     { email: 'thomas@givingstage.com', name: 'Thomas Shafer', type: 'to' }
#   ]
#   mergeVars: [
#     {
#       rcpt: 'jeffrey@givingstage.com',
#       templateVars:
#         name: 'Jeffrey Wescott'
#         first_name:'Jeffrey'
#         ...
#     }
#     {
#       rcpt: 'thomas@givingstage.com',
#       templateVars:
#         name: 'Thomas Shafer'
#         first_name: 'Thomas'
#         ...
#       ]
#     }
#   ]
module.exports.sendBatch = (options, callback)->
  callback ||= noop

  return callback('no template name provided') if _.str.isBlank(options.templateName)
  return callback('missing subject') if _.str.isBlank(options.subject)
  return callback('invalid recipients array') if !_.isArray(options.to)
  return callback('invalid merge variables array') if !_.isArray(options.mergeVars)
  return callback('invalid images array') if !_.isArray(options.images)
  _.defaults(options, fromName: 'cine.io', fromEmail: 'support@cine.io')

  # restructure the template variables into Mandrill-style merge variables
  options.globalMergeVars = _templateVarsToMergeVars(options.globalTemplateVars)
  delete options.globalTemplateVars

  # restructure the template variables into Mandrill-style merge variables
  for mvObj in options.mergeVars
    mvObj.vars = _templateVarsToMergeVars(mvObj.templateVars)
    delete mvObj.tempateVars

  templateMailer(options, callback)


# convert a hash into the Mandrill-style name/content vars array
_templateVarsToMergeVars = (templateVars)->
  for name, content of templateVars
    { name: name, content: content }
