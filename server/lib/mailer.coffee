accountMailer = Cine.server_lib('mailer/account_mailer')
exports.forgotPassword = accountMailer.forgotPassword
exports.welcomeEmail = accountMailer.welcomeEmail
exports.monthlyBill = accountMailer.monthlyBill
exports.underOneGibBill = accountMailer.underOneGibBill

adminMailer = Cine.server_lib('mailer/admin_mailer')
exports.admin = adminMailer
