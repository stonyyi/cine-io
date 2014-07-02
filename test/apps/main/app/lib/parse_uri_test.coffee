parseURI = Cine.lib('parse_uri')

describe 'parseURI', ->
  it 'parses properly', ->
    uri = parseURI('http://www.givingstage.com/part1/part2?the=query&part=here#cool-part')
    expect(uri.anchor).to.equal('cool-part')
    expect(uri.path).to.equal('/part1/part2')
    expect(uri.query).to.equal('the=query&part=here')
    expect(uri.host).to.equal('www.givingstage.com')
    expect(uri.protocol).to.equal('http')
