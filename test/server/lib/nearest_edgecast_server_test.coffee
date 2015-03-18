nearestEdgecastServer = Cine.server_lib('nearest_edgecast_server')

describe 'nearestEdgecastServer', ->

  test = (point, expectedCineIOEndpoint, expectedEdgecastEndpoint)->
    edgecastServer = nearestEdgecastServer(point.lat, point.lng)
    expect(edgecastServer.cineioEndpointCode).to.equal(expectedCineIOEndpoint)
    expect(edgecastServer.rtmpCDNCode).to.equal(expectedEdgecastEndpoint)

  it 'returns lax for denver, colorado', ->
    denverColorado =
      lat: 39.736887
      lng: -104.986947
    test(denverColorado, 'sfo1', 'lax')

  it 'returns dca for raleigh, north carolina', ->
    raleighNorthCarolina =
      lat: 35.780289
      lng: -78.640936
    test(raleighNorthCarolina, 'sfo1', 'lax')

  it 'returns ams for paris, france', ->
    parisFrance =
      lat: 48.856600
      lng: 2.353926
    test(parisFrance, 'lon1', 'ams')

  it 'returns fra for dijon, france', ->
    dijonFrance =
      lat: 47.321525
      lng: 5.041147
    test(dijonFrance, 'lon1', 'fra')

  it 'returns arn for moscow, russia', ->
    moscowRussia =
      lat: 55.754429
      lng: 37.625628
    test(moscowRussia, 'lon1', 'arn')

  it 'returns syd for aukland, new zealand', ->
    auklandNewZealand =
      lat: -36.850387
      lng: 174.763846
    test(auklandNewZealand, 'sfo1', 'syd')

  it 'returns arn for tokyo, japan', ->
    tokyoJapan =
      lat: 35.619218
      lng: 139.590912
    test(tokyoJapan, 'lon1', 'hhp')
