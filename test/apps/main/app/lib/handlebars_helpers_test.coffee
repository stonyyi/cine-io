Handlebars = require('rendr-handlebars')(entryPath: 'fake').Handlebars
handlebarsHelpers = Cine.lib('handlebars_helpers')
h = handlebarsHelpers(Handlebars)

describe 'handlebarsHelpers', ->
  describe 'ifEqual', ->
    it 'calls the fn when present', (done)->
      options = fn: (val)->
        expect(val).to.equal(h)
        done()
      h.ifEqual('abc', 'abc', options)

    it 'calls the inverse when not', (done)->
      options = inverse: (val)->
        expect(val).to.equal(h)
        done()
      h.ifEqual('abc', 123, options)
