DataAdapter = Cine.server_lib('data_adapter')

describe 'DataAdapter', ->
  describe 'constructor', ->
    it 'takes an app and options', ->
      app = "foo"
      da = new DataAdapter(app)
      expect(da.app).to.equal("foo")
  describe '#request', ->
    # This tests
    # Route matching works
    # The response is properly formatted
    # The input is properly passed in
    it 'returns the proper response', (done)->
      matchingRoute = {
        callbacks: [(params, callback)->
          expect(params.param1).to.equal('value1')
          callback(null, 'matching route response')
        ]
        match: (path)->
          expect(path).to.equal('/api/fake-path')
      }
      notMatchingRoute = {
        callbacks: [(params, callback)->
          callback(null, 'notmatching route response')
        ]
        match: (path)->
          path == 'do not match'
      }
      app = {routes: {post: [notMatchingRoute, matchingRoute]}}
      da = new DataAdapter(app)
      req = {method: 'post'}
      api = {path: '/fake-path', body: {param1: 'value1'}}
      da.request req, api, null, (err, options, response)->
        expect(err).to.equal(null)
        expect(options.statusCode).to.equal(200)
        expect(response).to.equal 'matching route response'
        done()

    it.only 'returns the proper response wrapped in a callback', (done)->
      matchingRoute = {
        callbacks: [(params, callback)->
          expect(params.param1).to.equal('value1')
          callback(null, hey: 'buddy')
        ]
        match: (path)->
          expect(path).to.equal('/api/fake-path')
      }
      notMatchingRoute = {
        callbacks: [(params, callback)->
          callback(null, 'notmatching route response')
        ]
        match: (path)->
          path == 'do not match'
      }
      app = {routes: {get: [notMatchingRoute, matchingRoute]}}
      da = new DataAdapter(app)
      req = {method: 'get'}
      api = {path: '/fake-path', body: {param1: 'value1', callback: 'fuun'}}
      da.request req, api, null, (err, options, response)->
        expect(err).to.equal(null)
        expect(options.statusCode).to.equal(200)
        expect(response).to.equal 'fuun({"hey":"buddy"});'
        done()

    it 'includes the user session to the params', (done)->
      matchingRoute = {
        callbacks: [(params, callback)->
          callback(null, params.sessionUserId)
        ]
        match: (path)->
          expect(path).to.equal('/api/fake-path')
      }
      app = {routes: {post: [matchingRoute]}}
      da = new DataAdapter(app)
      req = {method: 'post', user: 'some_user_id'}
      api = {path: '/fake-path', body: {param1: 'value1'}}
      da.request req, api, null, (err, options, response)->
        expect(err).to.equal(null)
        expect(options.statusCode).to.equal(200)
        expect(response).to.equal 'some_user_id'
        done()

    it 'appropriately sends errors', (done)->
      matchingRoute = {
        callbacks: [(params, callback)->
          callback("you ain't logged in", null, status: 401)
        ]
        match: (path)->
          expect(path).to.equal('/api/fake-path')
      }
      app = {routes: {post: [matchingRoute]}}
      da = new DataAdapter(app)
      req = {method: 'post'}
      api = {path: '/fake-path', body: {param1: 'value1'}}
      da.request req, api, null, (err, options, response)->
        expect(err.status).to.equal(401)
        expect(err.message).to.equal("you ain't logged in")
        expect(options.statusCode).to.equal(401)
        expect(response).to.equal(null)
        done()

    it 'appropriately sends errors with a response', (done)->
      matchingRoute = {
        callbacks: [(params, callback)->
          callback("you ain't logged in", {problem: 'here'}, status: 401)
        ]
        match: (path)->
          expect(path).to.equal('/api/fake-path')
      }
      app = {routes: {post: [matchingRoute]}}
      da = new DataAdapter(app)
      req = {method: 'post'}
      api = {path: '/fake-path', body: {param1: 'value1'}}
      da.request req, api, null, (err, options, response)->
        expect(err.status).to.equal(401)
        expect(err.message).to.equal("you ain't logged in")
        expect(err.problem).to.equal("here")
        expect(options.statusCode).to.equal(401)
        expect(response).to.deep.equal(problem: 'here')
        done()

    it 'responds to HEAD requests', (done)->
      matchingRoute = {
        callbacks: [(params, callback)->
          expect(params.param1).to.equal('value1')
          callback(null, 'matching route response')
        ]
        match: (path)->
          expect(path).to.equal('/api/fake-path')
      }
      app = {routes: {get: [matchingRoute]}}
      da = new DataAdapter(app)
      req = {method: 'HEAD'}
      api = {path: '/fake-path', body: {param1: 'value1'}}
      da.request req, api, null, (err, options, response)->
        expect(err).to.be.null
        expect(options.statusCode).to.equal(200)
        expect(response).to.equal('matching route response')
        done()
