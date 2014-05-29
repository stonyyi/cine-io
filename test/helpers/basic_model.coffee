_ = require 'underscore'
_str = require 'underscore.string'

module.exports = (modelName, options={})->
  _.defaults(options, url: _str.dasherize(modelName), id: 'id')
  modelClassName = _str.classify(modelName)
  Model = Cine.model(modelName)

  describe "Basic Model: #{modelClassName}", ->
    it 'has an id', ->
      expect(Model.id).to.equal(modelClassName)

    it 'has a url', ->
      c = new Model
      url = "/#{options.url}"
      if options.urlAttributes
        params = _.map options.urlAttributes.sort(), (attribute)->
          "#{attribute}=:#{attribute}"
        url += "?#{params.join("&")}"
      expect(c.url).to.equal(url)

    it 'has an id attribute', ->
      c = new Model
      expect(c.idAttribute).to.equal(options.id)
