app = Cine.require('app').app
test = require('supertest')
describe 'homepage', ->
  it 'should render the homepage-show', (done)->
    test(app)
    .get('/')
    .set('Accept', 'application/html')
    .expect('Content-Type', /html/)
    .expect(200, /<div class="homepage-show"/, done)
