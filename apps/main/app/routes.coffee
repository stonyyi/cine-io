module.exports = (match) ->
  match "", "homepage#show"
  match "/account", "account#edit"
  # For some reason this doesn't work.
  # match '/legal(/:id)', 'legal#show'
  match '/legal', 'legal#show'
  match '/legal/:id', 'legal#show'

  match '/docs', 'docs#show'
