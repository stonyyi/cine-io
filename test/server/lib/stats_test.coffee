redis  = require('redis')
Stats = Cine.server_lib("stats")
_ = require('underscore')
_str = require('underscore.string')

describe 'Stats', ->
  it 'has two stats', ->
    expect(Stats.statsNames).to.have.length(2)

  _.each Stats.statsNames, (statName)->
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

  describe 'getAll', ->
    beforeEach (done)->
      Stats.setUsage(the: 'bandwidth', done)
    beforeEach (done)->
      Stats.setSignups(these: 'new users', done)

    it 'returns all the stats', (done)->
      Stats.getAll (err, results)->
        expect(err).to.be.null
        expect(results).to.deep.equal(usage: {the: 'bandwidth'}, signups: {these: 'new users'})
        done()
