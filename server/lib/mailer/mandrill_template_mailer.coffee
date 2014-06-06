mandrillConfig = Cine.config('variables/mandrill')
Mandrill = require('mandrill-api').Mandrill
mandrill = new Mandrill(mandrillConfig.api_key)

sendEmail = (options, callback)->
  # see: https://mandrillapp.com/api/docs/messages.JSON.html#method=send-template
  emailOptions =
    template_name: options.templateName
    template_content: [ { name: "IGNORE", content: "THIS" } ]
    message:
      subject: options.subject
      from_email: options.fromEmail
      from_name: options.fromName
      attachments: options.attachments
      important: false
      track_opens: true
      track_clicks: true
      auto_text: true
      auto_html: true
      inline_css: true
      merge: true
      preserve_recipients: false
      async: options.to.length > 1  # set to true if sending many emails at same time
      global_merge_vars: options.globalMergeVars
      # global_merge_vars is an array of objects
      #   { name: "event_title", content: eventTitle }
      #   { name: "event_description", content: eventDescription }
      #   { name: "event_url", content: eventUrl }
      to: options.to  # array of objects: { email: recipientEmail, name: recipientName, type: "to" }
      merge_vars: options.mergeVars
      # merge_vars is an array of objects
      # merge_vars[n].rcpt is an email address used to match variables to recipient
      # merge_vars[n][m].name is the template variable name
      # merge_vars[n][m].content is the template variable data
      # [
      #   {
      #     rcpt: recipientEmail,
      #     vars: [
      #       { name: "name", content: recipientName }
      #       { name: "first_name", content: recipientName.split(' ')[0] }
      #       { name:"organization", content: eventOrganization }
      #       { name:"donation_currency", content: donationCurrency }
      #       { name: "donation_amount", content: donationAmount }
      #       { name: "artist", content: eventArtist }
      #     ]
      #   }
      # ]
      images: options.images  # array of objects: { type: "image/png", name: "LOGO_IMAGE", content: logoImageData }

  if process.env.NODE_ENV not in ['production', 'test']
    Cine.server_lib('mailer/mail_safe')(emailOptions.message)

  # console.debug('sending email', emailOptions)
  mandrill.messages.sendTemplate emailOptions, (response)->
    callback(null, response)

module.exports = sendEmail
module.exports._mandrill = mandrill
