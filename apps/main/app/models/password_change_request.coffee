Base = Cine.model('base')

module.exports = class PasswordChangeRequest extends Base
  @id: 'PasswordChangeRequest'
  url: '/password-change-request'
