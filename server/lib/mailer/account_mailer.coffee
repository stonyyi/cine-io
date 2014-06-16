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

exports.welcomeEmail = (user, callback=noop)->
  name = user.name || user.email
  mailOptions =
    templateName: 'blank-with-header-and-footer'
    subject: 'Welcome to cine.io.'
    toEmail: user.email
    toName: name
    userTemplateVars:
      header_blurb: 'Welcome to cine.io.'
      name: name
      content: """
      <p>Welcome to <a href='https://www.cine.io'>cine.io</a>!</p>
      <p>All of our APIs and common workflows are documented on our <a href='https://www.cine.io/docs'>documentation page</a>.</p>
      <p>We have a <a href="https://github.com/cine-io/js-sdk">JavaScript SDK</a> for easy playing and publishing live streams.</p>
      <p>We have server side packages for <a href="https://github.com/cine-io/cineio-ruby">ruby</a>, <a href="https://github.com/cine-io/cineio-node">node</a>, and <a href="https://github.com/cine-io/cineio-python">python</a>.</p>
      <p>We also have an <a href="https://github.com/cine-io/cineio-ios">iOS pod</a>, with Android coming soon.</p>
      <p>All of our repositories and some sample apps can be found on our  <a href="http://git.cine.io">Github page</a>.</p>
      <p>Don't hesitate to contact us if you have any questions or comments.</p>
      <p>Regards,<br/>
      Thomas Shafer<br/>
      Technical Officer, cine.io</p>
      """
  sendMail mailOptions, callback
