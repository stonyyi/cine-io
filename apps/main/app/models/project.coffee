Base = Cine.model('base')
Streams = Cine.collection('streams')
isServer = typeof window is 'undefined'

module.exports = class Project extends Base
  @id: 'Project'
  url: if isServer then "/project?publicKey=:publicKey" else "/project"

  @plans: ['free', 'solo', 'startup', 'enterprise']

  getStreams: ->
    return @streams if @streams
    @streams = new Streams([], app: @app)
    @streams.fetch({data: secretKey: @get('secretKey')})
    @streams
