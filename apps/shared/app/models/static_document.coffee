Base = Cine.model('base')

module.exports = class StaticDocument extends Base
  @id: 'StaticDocument'
  url: '/static-document?id=:id'
  idAttribute: 'id'
