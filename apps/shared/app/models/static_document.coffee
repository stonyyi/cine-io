Base = Cine.model('base')
isServer = typeof window is 'undefined'

module.exports = class StaticDocument extends Base
  @id: 'StaticDocument'
  url: if isServer then '/static-document?id=:id' else '/static-document'
  idAttribute: 'id'
