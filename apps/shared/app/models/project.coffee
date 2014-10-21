Base = Cine.model('base')
Streams = Cine.collection('streams')

module.exports = class Project extends Base
  @id: 'Project'
  url: "/project?publicKey=:publicKey"

  getStreams: ->
    return @streams if @streams
    @streams = new Streams([], app: @app)
    @streams.fetch(data: {secretKey: @get('secretKey')})
    @streams

  @include Cine.lib('date_value')

  updatedAt: ->
    @_dateValue('updatedAt')
