Base = Cine.model('base')
isServer = typeof window is 'undefined'

module.exports = class Account extends Base
  @id: 'Account'
  url: if isServer then "/account?masterKey=:masterKey" else "/account"
  idAttribute: 'masterKey'
  @plans: ['free', 'solo', 'startup', 'enterprise']

  isHeroku: ->
    !!@get('herokuId')
