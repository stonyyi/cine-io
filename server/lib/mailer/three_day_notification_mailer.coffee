getMailerLogo = Cine.server_lib('mailer/get_mailer_logo')
sendTemplateEmail = Cine.server_lib('mailer/send_template_email')

noop = ->

ENJOY_AND_QUESTIONS = """
<p>We hope you enjoy using <a href="https://www.cine.io">cine.io</a>. If you have any questions you can reply to this email, or send us an email at <a href="mailto:support@cine.io">support@cine.io</a>.</p>
"""

sendMail = (mailOptions, callback)->
  getMailerLogo (err, logoImageData)->
    images = []
    images.push type: "image/png", name: "LOGO_IMAGE", content: logoImageData if !err and logoImageData
    mailOptions.images = images

    sendTemplateEmail.send mailOptions, callback

genericThreeDayNotification = (account, middleText, callback)->
  name = account.name || account.billingEmail
  mailOptions =
    templateName: 'blank-with-header-and-footer'
    subject: 'Welcome to cine.io.'
    toEmail: account.billingEmail
    toName: name
    userTemplateVars:
      header_blurb: 'Welcome to cine.io.'
      name: name
      content: """
      <p>
        It's been a few days since you signed up for <a href='https://www.cine.io'>cine.io</a>.
        I wanted to check in to see how things are going.
      </p>
      <br/>
      #{middleText}
      <br/>
      <p>All of our SDKs are open source on our <a href="http://git.cine.io">Github page</a>.</p>
      <br/>
      <p>#{ENJOY_AND_QUESTIONS}</p>
      <br/>
      <p>Happy Coding!</p>
      <p>Regards,<br/>
      Thomas Shafer<br/>
      Technical Officer, cine.io</p>
      """
  sendMail mailOptions, callback

exports.haventDoneAnything = (account, callback=noop)->
  text = """
    <p>
      Looks like you haven't streamed anything nor used any peer minutes.
      I'm checking in to see if there's anything I can do to to help you get setup.
    </p>
    <br/>
    <p>
      We have some sample broadcast applications that can be run on <a href='https://github.com/cine-io/cineio-broadcast-ios-example-app'>iOS</a> and <a href='https://github.com/cine-io/cineio-broadcast-android'>Android</a>.
      As well as sample peer applications on <a href='https://github.com/cine-io/cineio-peer-android'>Android</a> and <a href='https://github.com/cine-io/cineio-meetups'>web</a>.
      Have you had a chance to check out <a href='http://developer.cine.io/'>our documentation</a>?
    </p>
    <br/>
    <p>
      We're here to help and want to make the integration as easy as possible.
    </p>
  """
  genericThreeDayNotification account, text, callback

exports.didSendBandwidth = (account, callback=noop)->
  text = """
    <p>
      Looks like you were able to get setup using our live streaming broadcast product. That's awesome!
    </p>
    <br/>
    <p>
      We love getting to know our customers. What kind of app are you working on? Have you run into any snags with our SDKs or API? Anything we could add or change?
      We're always looking for ways to improve.
      You can always send an email to say hi too.
    </p>
  """
  genericThreeDayNotification account, text, callback

exports.didSendPeer = (account, callback=noop)->
  text = """
    <p>
      Looks like you were able to get setup using our peer to peer chat product. That's awesome!
    </p>
    <br/>
    <p>
      We love getting to know our customers. What kind of app are you working on? Have you run into any snags with our SDKs or API? Anything we could add or change?
      We're always looking for ways to improve.
      You can always send an email to say hi too.
    </p>
  """
  genericThreeDayNotification account, text, callback
