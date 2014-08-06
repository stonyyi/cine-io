app = Cine.require('app').app
test = require('supertest')

describe 'the embed app', ->
  it 'should render the embed static page', (done)->
    test(app)
    .get('/embed/abc/123')
    .set('Accept', 'application/html')
    .expect('Content-Type', /html/)
    .expect(200, /<title>cine.io player embed<\/title>/, done)
