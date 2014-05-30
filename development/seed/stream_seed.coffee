EdgecastStream = Cine.server_model('edgecast_stream')
Project = Cine.server_model('project')
async = require('async')
_ = require('underscore')

edgecastStreams = [
  {instanceName: "stages", eventName: "stage1", streamName: "stage1", streamKey: "go", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage2", streamName: "stage2", streamKey: "world", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage3", streamName: "stage3", streamKey: "earth", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage4", streamName: "stage4", streamKey: "music", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage5", streamName: "stage5", streamKey: "notes", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage6", streamName: "stage6", streamKey: "band", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage7", streamName: "stage7", streamKey: "group", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage8", streamName: "stage8", streamKey: "fans", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage9", streamName: "stage9", streamKey: "rock", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage10", streamName: "stage10", streamKey: "tune", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage11", streamName: "stage11", streamKey: "creative", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage12", streamName: "stage12", streamKey: "piano", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage13", streamName: "stage13", streamKey: "guitar", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage14", streamName: "stage14", streamKey: "drums", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage15", streamName: "stage15", streamKey: "song", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage16", streamName: "stage16", streamKey: "violin", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage17", streamName: "stage17", streamKey: "cello", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage18", streamName: "stage18", streamKey: "harp", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage19", streamName: "stage19", streamKey: "trumpet", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage20", streamName: "stage20", streamKey: "keyboard", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage21", streamName: "stage21", streamKey: "treble", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage22", streamName: "stage22", streamKey: "bass", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage23", streamName: "stage23", streamKey: "cleff", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage24", streamName: "stage24", streamKey: "chord", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage25", streamName: "stage25", streamKey: "encore", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage26", streamName: "stage26", streamKey: "harmony", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage27", streamName: "stage27", streamKey: "major", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage28", streamName: "stage28", streamKey: "minor", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage29", streamName: "stage29", streamKey: "pitch", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage30", streamName: "stage30", streamKey: "prelude", expiration: '2/1/2015'}
  {instanceName: "stages", eventName: "stage31", streamName: "stage31", streamKey: "sharp", expiration: '2/1/2015'}
  {instanceName: 'stages', eventName: 'stage32', streamName: 'stage32', streamKey: 'prelude39', expiration: '4/8/2015'}
  {instanceName: 'stages', eventName: 'stage33', streamName: 'stage33', streamKey: 'creative59', expiration: '4/8/2015'}
  {instanceName: 'stages', eventName: 'stage34', streamName: 'stage34', streamKey: 'treble12', expiration: '4/8/2015'}
  {instanceName: 'stages', eventName: 'stage35', streamName: 'stage35', streamKey: 'go25', expiration: '4/8/2015'}
  {instanceName: 'stages', eventName: 'stage36', streamName: 'stage36', streamKey: 'music42', expiration: '4/8/2015'}
  {instanceName: 'stages', eventName: 'stage37', streamName: 'stage37', streamKey: 'group43', expiration: '4/8/2015'}
  {instanceName: 'stages', eventName: 'stage38', streamName: 'stage38', streamKey: 'music8', expiration: '4/8/2015'}
  {instanceName: 'stages', eventName: 'stage39', streamName: 'stage39', streamKey: 'piano37', expiration: '4/8/2015'}
  {instanceName: 'stages', eventName: 'stage40', streamName: 'stage40', streamKey: 'keyboard46', expiration: '4/8/2034'}
  {instanceName: 'stages', eventName: 'stage41', streamName: 'stage41', streamKey: 'cello45', expiration: '4/8/2034'}
]

module.exports = (projects, callback)->
  console.log('creating edgecast_streams')

  fetchRandomProject = ->
    _.sample projects

  iterator = (stream, callback)->
    stream = new EdgecastStream(stream)
    addProject = Math.random() < 0.3
    if addProject
      project = fetchRandomProject(projects)
      stream._project = project._id
      stream.assignedAt = new Date

    stream.save (err, stream)->
      return callback(err, stream) if err
      return callback(err, stream) unless project
      Project.increment project, 'streamsCount', 1,  (err, updatedAttributes)->
        callback(err, stream)
  async.each edgecastStreams, iterator, callback
