exports.show = (params,callback)->
  console.log('showing Component#show', params)
  return callback(status: 404) unless @app.attributes.env == 'development'

  callback(null, component: params.id)
