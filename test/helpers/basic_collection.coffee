_ = require 'underscore'
_str = require 'underscore.string'

module.exports = (collectionName, options={})->
  _.defaults(options, url: _str.dasherize(collectionName))
  collectionClassName = _str.classify(collectionName)
  Collection = Cine.collection(collectionName)
  model_name = collectionName.substr(0, collectionName.length-1)
  Model = Cine.model(model_name)


  describe "Basic Collection: #{collectionClassName}", ->
    it 'has an id', ->
      expect(Collection.id).to.equal(collectionClassName)

    it 'has a url', ->
      c = new Collection
      expect(c.url).to.equal("/#{options.url}")

    it 'has a model', ->
      c = new Collection
      expect(c.model).to.equal(Model)
