setTitleAndDescription = Cine.lib('set_title_and_description')

exports.show = (params, callback)->
  setTitleAndDescription @app
  callback()

exports.pricing = (params, callback)->
  setTitleAndDescription @app
  callback()
