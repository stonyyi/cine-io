redis  = require('redis')
Stats = Cine.server_lib("stats")
_str = require('underscore.string')

describe 'Stats', ->
  test = (statName)->
    describe statName, ->
      it "can save values and then be fetched", (done)->
        capsName = _str.capitalize(statName)
        Stats["set#{capsName}"] some: "sweet stats", (err, reply)->
          expect(err).to.be.null
          expect(reply).to.equal(1)
          Stats["get#{capsName}"] (err, result)->
            expect(err).to.be.null
            expect(result).to.deep.equal(some: "sweet stats")
            done()

  test 'usage'
  test 'signups'
