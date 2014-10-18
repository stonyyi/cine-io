redis  = require('redis')
Stats = Cine.server_lib("stats")
_ = require('underscore')
_str = require('underscore.string')
moment = require('moment')

describe 'Stats', ->
  it 'has two stats', ->
    expect(Stats.statsNames).to.have.length(2)

  _.each Stats.statsNames, (statName)->
    describe statName, ->
      it "can save values and then be fetched", (done)->
        month = new Date
        capsName = _str.capitalize(statName)
        Stats["set#{capsName}"] month, some: "sweet stats", (err, reply)->
          expect(err).to.be.null
          expect(reply).to.equal(1)
          Stats["get#{capsName}"] month, (err, result)->
            expect(err).to.be.null
            expect(result).to.deep.equal(some: "sweet stats")
            done()

  describe 'getAll', ->
    beforeEach ->
      @month = new Date
    beforeEach (done)->
      Stats.setUsage(@month, the: 'bandwidth', done)
    beforeEach (done)->
      Stats.setSignups(@month, these: 'new users', done)

    it 'returns all the stats', (done)->
      Stats.getAll (err, results)=>
        expect(err).to.be.null
        expected = {}
        expected["usage-#{moment(@month).format('YYYY-MM')}"] = {the: 'bandwidth'}
        expected["signups-#{moment(@month).format('YYYY-MM')}"] = {these: 'new users'}
        expect(results).to.deep.equal(expected)
        done()
