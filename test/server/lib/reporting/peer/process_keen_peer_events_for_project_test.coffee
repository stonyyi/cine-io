processKeenPeerEventsForProject = Cine.server_lib('reporting/peer/process_keen_peer_events_for_project')

describe 'processKeenPeerEventsForProject', ->
  beforeEach ->
    @projectId = "540e53cc3e64372c009cda6f"
    @peerEvents = requireFixture('keen/peer_reporting_for_project')

  it 'aggregates the events for a total time per user per room', (done)->
    processKeenPeerEventsForProject @projectId, @peerEvents, (err, totalTimeInMs)->
      expect(err).to.be.null
      expect(totalTimeInMs).to.equal(623066)
      done()
