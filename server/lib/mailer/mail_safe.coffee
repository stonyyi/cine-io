_ = require('underscore')

mailSafeRegexp = /^.*@cine\.io$/
rejectUnacceptableEmails = (emailArray)->
  _.select emailArray, (toField)->
    mailSafeRegexp.test(toField.email)

module.exports = (mailOptions)->
  mailOptions.to = rejectUnacceptableEmails(mailOptions.to)
  mailOptions.cc = rejectUnacceptableEmails(mailOptions.cc)
  mailOptions.bcc = rejectUnacceptableEmails(mailOptions.bcc)
