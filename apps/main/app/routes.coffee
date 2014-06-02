module.exports = (match) ->
  match "", "homepage#show"
  match "/login", "sessions#new"
  match "/project/:publicKey", "projects#show"

  # For some reason this doesn't work.
  # match '/legal(/:id)', 'legal#show'
  match '/legal', 'legal#show'
  match '/legal/:id', 'legal#show'

  match '/docs', 'docs#show'
