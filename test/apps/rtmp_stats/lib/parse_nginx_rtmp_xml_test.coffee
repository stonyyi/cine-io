parseNginxRtmpXml = Cine.app('rtmp_stats/lib/parse_nginx_rtmp_xml')
fs = require('fs')

describe 'ParseNginxRtmpXsl', ->
  beforeEach ->
    @stats = fs.readFileSync(Cine.path('test/fixtures/fake_nginx_rtmp_xml.xml'), encoding: 'utf8')

  it 'parses an nginx rtmp xml', (done)->
    parseNginxRtmpXml @stats, (err, result)->
      expect(err).to.be.null
      expect(result.input.total).to.equal(2)
      expect(result.input.streams).to.deep.equal({"7k-lyoPB": {bitrate: 1303616}, "7k-lyoP": {bitrate: 0}})
      expect(result.output.total).to.equal(2)
      expect(result.output.streams['7k-lyoPB']).to.equal(2)
      expect(result.output.streams['7k-lyoP']).to.equal(0)
      done()
