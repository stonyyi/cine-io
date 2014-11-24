DataAdapter = Cine.server_lib('data_adapter')

describe 'DataAdapter', ->
  describe 'constructor', ->
    it 'takes an app and options', ->
      routes = "foo"
      da = new DataAdapter(routes)
      expect(da.routes).to.equal("foo")
  describe '#request', ->
    # This tests
    # Route matching works
    # The response is properly formatted
    # The input is properly passed in
    it 'returns the proper response', (done)->
      matchingRoute = (params, callback)->
        expect(params.param1).to.equal('value1')
        callback(null, 'matching route response')
      wrongMethod = (params, callback)->
        expect(params.param1).to.equal('value1')
        callback(null, 'wrong method route response')
      notMatchingRoute = (params, callback)->
        callback(null, 'notmatching route response')
      routes =
        post:
          'do not match': notMatchingRoute
          '/fake-path': matchingRoute
        get:
          '/fake-path': wrongMethod
      da = new DataAdapter(routes)
      req = {method: 'post', headers: {}, connection: {}}
      api = {path: '/fake-path', body: {param1: 'value1'}}
      da.request req, api, null, (err, options, response)->
        expect(err).to.equal(null)
        expect(options.statusCode).to.equal(200)
        expect(options.jsonp).to.be.undefined
        expect(response).to.equal 'matching route response'
        done()

    it 'returns the proper response with jsonp', (done)->
      matchingRoute = (params, callback)->
        expect(params.param1).to.equal('value1')
        callback(null, hey: 'buddy')
      notMatchingRoute = (params, callback)->
        callback(null, 'notmatching route response')
      routes = {'get': {'do not match': notMatchingRoute, '/fake-path': matchingRoute}}
      da = new DataAdapter(routes)
      req = {method: 'get', headers: {}, connection: {}}
      api = {path: '/fake-path', body: {param1: 'value1', callback: 'fuun'}}
      da.request req, api, null, (err, options, response)->
        expect(err).to.equal(null)
        expect(options.statusCode).to.equal(200)
        expect(options.jsonp).to.equal(true)
        expect(response).to.deep.equal hey: 'buddy'
        done()

    it 'includes the user session to the params', (done)->
      matchingRoute = (params, callback)->
        callback(null, params.sessionUserId)
      app = {'post': {'/fake-path': matchingRoute}}
      da = new DataAdapter(app)
      req = {method: 'post', user: 'some_user_id', headers: {}, connection: {}}
      api = {path: '/fake-path', body: {param1: 'value1'}}
      da.request req, api, null, (err, options, response)->
        expect(err).to.equal(null)
        expect(options.statusCode).to.equal(200)
        expect(response).to.equal 'some_user_id'
        done()

    describe 'ip address', ->
      it 'prefers the x-forwarded-for header', (done)->
        matchingRoute = (params, callback)->
          callback(null, params.remoteIpAddress)
        app = {'post': {'/fake-path': matchingRoute}}
        da = new DataAdapter(app)
        req = {method: 'post', user: 'some_user_id', headers: {'x-forwarded-for': '123'}, connection: {remoteAddress: '456'}}
        api = {path: '/fake-path', body: {param1: 'value1'}}
        da.request req, api, null, (err, options, response)->
          expect(err).to.equal(null)
          expect(options.statusCode).to.equal(200)
          expect(response).to.equal '123'
          done()

      it 'prefers the returns to the remoteAddress header', (done)->
        matchingRoute = (params, callback)->
          callback(null, params.remoteIpAddress)
        app = {'post': {'/fake-path': matchingRoute}}
        da = new DataAdapter(app)
        req = {method: 'post', user: 'some_user_id', headers: {}, connection: {remoteAddress: '456'}}
        api = {path: '/fake-path', body: {param1: 'value1'}}
        da.request req, api, null, (err, options, response)->
          expect(err).to.equal(null)
          expect(options.statusCode).to.equal(200)
          expect(response).to.equal '456'
          done()

      it 'will otherwise be undefined', (done)->
        matchingRoute = (params, callback)->
          callback(null, params.remoteIpAddress)
        app = {'post': {'/fake-path': matchingRoute}}
        da = new DataAdapter(app)
        req = {method: 'post', user: 'some_user_id', headers: {}, connection: {}}
        api = {path: '/fake-path', body: {param1: 'value1'}}
        da.request req, api, null, (err, options, response)->
          expect(err).to.equal(null)
          expect(options.statusCode).to.equal(200)
          expect(response).to.be.undefined
          done()

    it 'appropriately sends errors', (done)->
      matchingRoute = (params, callback)->
        callback("you ain't logged in", null, status: 401)
      app = {'post': {'/fake-path': matchingRoute}}
      da = new DataAdapter(app)
      req = {method: 'post', headers: {}, connection: {}}
      api = {path: '/fake-path', body: {param1: 'value1'}}
      da.request req, api, null, (err, options, response)->
        expect(err.status).to.equal(401)
        expect(err.message).to.equal("you ain't logged in")
        expect(options.statusCode).to.equal(401)
        expect(response).to.equal(null)
        done()

    it 'appropriately sends errors with a response', (done)->
      matchingRoute = (params, callback)->
        callback("you ain't logged in", {problem: 'here'}, status: 401)
      app = {'post': {'/fake-path': matchingRoute}}
      da = new DataAdapter(app)
      req = {method: 'post', headers: {}, connection: {}}
      api = {path: '/fake-path', body: {param1: 'value1'}}
      da.request req, api, null, (err, options, response)->
        expect(err.status).to.equal(401)
        expect(err.message).to.equal("you ain't logged in")
        expect(err.problem).to.equal("here")
        expect(options.statusCode).to.equal(401)
        expect(response).to.deep.equal(problem: 'here')
        done()

    it 'responds to HEAD requests', (done)->
      matchingRoute = (params, callback)->
        expect(params.param1).to.equal('value1')
        callback(null, 'matching route response')
      app = {'get': {'/fake-path': matchingRoute}}
      da = new DataAdapter(app)
      req = {method: 'HEAD', headers: {}, connection: {}}
      api = {path: '/fake-path', body: {param1: 'value1'}}
      da.request req, api, null, (err, options, response)->
        expect(err).to.be.null
        expect(options.statusCode).to.equal(200)
        expect(response).to.equal('matching route response')
        done()
