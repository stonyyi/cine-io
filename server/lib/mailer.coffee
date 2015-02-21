accountMailer = Cine.server_lib('mailer/account_mailer')
threeDayNotificationMailer = Cine.server_lib('mailer/three_day_notification_mailer')

exports.forgotPassword = accountMailer.forgotPassword
exports.welcomeEmail = accountMailer.welcomeEmail
exports.monthlyBill = accountMailer.monthlyBill
exports.underOneGibBill = accountMailer.underOneGibBill
exports.throttledAccount = accountMailer.throttledAccount
exports.automaticallyUpgradedAccount = accountMailer.automaticallyUpgradedAccount
exports.willUpgradeAccount = accountMailer.willUpgradeAccount

exports.haventDoneAnything = threeDayNotificationMailer.haventDoneAnything
exports.didSendPeer = threeDayNotificationMailer.didSendPeer
exports.didSendBandwidth = threeDayNotificationMailer.didSendBandwidth

adminMailer = Cine.server_lib('mailer/admin_mailer')
exports.admin = adminMailer
