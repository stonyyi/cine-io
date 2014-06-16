domain = Cine.config('variables/mailer_domain')
getMailerLogo = Cine.server_lib('mailer/get_mailer_logo')
sendTemplateEmail = Cine.server_lib('mailer/send_template_email')
noop = ->

sendMail = (mailOptions, callback)->
  getMailerLogo (err, logoImageData)->
    images = []
    images.push type: "image/png", name: "LOGO_IMAGE", content: logoImageData if !err and logoImageData
    mailOptions.images = images

    sendTemplateEmail.send mailOptions, callback

exports.forgotPassword = (user, passwordChangeRequest, callback=noop)->
  actionUrl = "https://#{domain}/recover-password/#{passwordChangeRequest.identifier}"
  mailOptions =
    templateName: 'simple-user-action-link'
    subject: 'Reset your password'
    toEmail: user.email
    toName: user.name
    userTemplateVars:
      header_blurb: 'Reset your password'
      name: user.name
      lead_copy: "<p>Someone recently requested that the password be reset for #{user.email}.</p>"
      action_copy: "Click here to reset your password."
      action_url: actionUrl
      followup_copy: "<p>If this is a mistake just ignore this email &mdash; your password will not be changed.</p>"
  sendMail mailOptions, callback
