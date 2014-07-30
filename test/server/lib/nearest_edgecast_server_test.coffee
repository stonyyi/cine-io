nearestEdgecastServer = Cine.server_lib('nearest_edgecast_server')

describe 'nearestEdgecastServer', ->

  test = (point, expected)->
    edgecastServer = nearestEdgecastServer(point.lat, point.lng)
    expect(edgecastServer.code).to.equal(expected)

  it 'returns lax for denver, colorado', ->
    denverColorado =
      lat: 39.736887
      lng: -104.986947
    test(denverColorado, 'lax')

  it 'returns dca for raleigh, north carolina', ->
    raleighNorthCarolina =
      lat: 35.780289
      lng: -78.640936
    test(raleighNorthCarolina, 'dca')

  it 'returns ams for paris, france', ->
    parisFrance =
      lat: 48.856600
      lng: 2.353926
    test(parisFrance, 'ams')

  it 'returns fra for dijon, france', ->
    dijonFrance =
      lat: 47.321525
      lng: 5.041147
    test(dijonFrance, 'fra')

  it 'returns arn for moscow, russia', ->
    moscowRussia =
      lat: 55.754429
      lng: 37.625628
    test(moscowRussia, 'arn')

  it 'returns syd for aukland, new zealand', ->
    auklandNewZealand =
      lat: -36.850387
      lng: 174.763846
    test(auklandNewZealand, 'syd')

  it 'returns arn for tokyo, japan', ->
    tokyoJapan =
      lat: 35.619218
      lng: 139.590912
    test(tokyoJapan, 'hhp')
