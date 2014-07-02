_str = require 'underscore.string'

module.exports = (id)->
  describe "View: #{id}", ->
    ViewClass = Cine.view(id)
    expectedClassName = id.replace('/', '-')
    parts = id.split('/')
    displayName = [_str.classify(parts[0]), _str.classify(parts[1])].join('')

    before ->
      @instance = new ViewClass(app: mainApp)

    it "has an id", ->
      expect(ViewClass.id).to.equal(id)

    it "has a classname of: #{expectedClassName}", ->
      expect(@instance.className).to.equal(expectedClassName)

    it "has a component with the display name of: #{displayName}", ->
      expect(@instance.Component.type.displayName).to.equal(displayName)
