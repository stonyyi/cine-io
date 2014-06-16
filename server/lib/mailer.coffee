accountMailer = Cine.server_lib('mailer/account_mailer')
exports.forgotPassword = accountMailer.forgotPassword
exports.welcomeEmail = accountMailer.welcomeEmail

adminMailer = Cine.server_lib('mailer/admin_mailer')
exports.admin = adminMailer
