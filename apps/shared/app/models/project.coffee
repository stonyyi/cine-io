Base = Cine.model('base')
Streams = Cine.collection('streams')
isServer = typeof window is 'undefined'

module.exports = class Project extends Base
  @id: 'Project'
  url: if isServer then "/project?publicKey=:publicKey" else "/project"

  getStreams: ->
    return @streams if @streams
    @streams = new Streams([], app: @app)
    @streams.fetch({data: secretKey: @get('secretKey')})
    @streams

  @include Cine.lib('date_value')

  updatedAt: ->
    @_dateValue('updatedAt')
