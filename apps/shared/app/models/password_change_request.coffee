Base = Cine.model('base')
isServer = typeof window is 'undefined'

module.exports = class PasswordChangeRequest extends Base
  @id: 'PasswordChangeRequest'
  url: if isServer then "/password-change-request?identifier=:identifier" else "/password-change-request"
