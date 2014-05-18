module.exports = (match) ->
  match "", "homepage#show"
  match "/login", "sessions#new"
  match "/project/:apiKey", "projects#show"
