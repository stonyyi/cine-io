setTitleAndDescription = Cine.lib('set_title_and_description')

exports.show = (params,callback)->
  console.log('showing Component#show', params)
  setTitleAndDescription @app
  return callback(status: 404) unless @app.attributes.env == 'development'

  callback(null, component: params.id)
