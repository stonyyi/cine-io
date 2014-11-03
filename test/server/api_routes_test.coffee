supertest = require('supertest')
app = Cine.require('app').app
InternalApiRequest = Cine.server_lib('data_adapter').InternalApiRequest

describe 'api routes', ->

  beforeEach ->
    @agent = supertest.agent(app)

  afterEach ->
    InternalApiRequest.prototype.request.restore()

  httpMethodToSuperagentMethod =
    get: 'get'
    post: 'post'
    put: 'put'
    destroy: 'del'

  testRoute = (options)->
    {url, method, api} = options
    it "routes to #{api}", (done)->
      sinon.stub InternalApiRequest.prototype, 'request', (callback)->
        c = @_controller()
        expect(c).to.equal(Cine.api(api))
        callback(null, success: true)
      @agent[httpMethodToSuperagentMethod[method]](url).expect(200).end (err, res)->
        expect(JSON.parse(res.text)).to.deep.equal(success: true)
        done(err)

  testRoute api: 'server/nearest', method: 'get', url: '/api/1/-/nearest-server'

  testRoute api: 'health/index', method: 'get', url: '/api/1/-/health'

  testRoute api: 'projects/index', method: 'get'    , url: '/api/1/-/projects'
  testRoute api: 'projects/show', method: 'get'    ,   url: '/api/1/-/project'
  testRoute api: 'projects/create', method: 'post'   , url: '/api/1/-/project'
  testRoute api: 'projects/update', method: 'put'    , url: '/api/1/-/project'
  testRoute api: 'projects/delete', method: 'destroy', url: '/api/1/-/project'

  testRoute api: 'streams/index', method: 'get'    , url: '/api/1/-/streams'
  testRoute api: 'streams/show', method: 'get'    ,   url: '/api/1/-/stream'
  testRoute api: 'streams/create', method: 'post'   , url: '/api/1/-/stream'
  testRoute api: 'streams/update', method: 'put'    , url: '/api/1/-/stream'
  testRoute api: 'streams/delete', method: 'destroy', url: '/api/1/-/stream'

  testRoute api: 'stream_recordings/index', method: 'get', url: '/api/1/-/stream/recordings'
  testRoute api: 'stream_recordings/delete', method: 'destroy', url: '/api/1/-/stream/recording'

  testRoute api: 'static_documents/show', method: 'get', url: '/api/1/-/static-document'

  testRoute api: 'usage_reports/show', method: 'get', url: '/api/1/-/usage-report'

  testRoute api: 'users/show', method: 'get' , url: '/api/1/-/user'
  testRoute api: 'users/update_account', method: 'post', url: '/api/1/-/update-account'
  testRoute api: 'users/update', method: 'put' , url: '/api/1/-/user'

  testRoute api: 'accounts/index', method: 'get' , url: '/api/1/-/accounts'
  testRoute api: 'accounts/update', method: 'put' , url: '/api/1/-/account'
  testRoute api: 'accounts/delete', method: 'destroy' , url: '/api/1/-/account'

  testRoute api: 'password_change_requests/show', method: 'get' , url: '/api/1/-/password-change-request'
  testRoute api: 'password_change_requests/create', method: 'post', url: '/api/1/-/password-change-request'
