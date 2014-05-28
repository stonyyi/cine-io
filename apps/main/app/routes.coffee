module.exports = (match) ->
  match "", "homepage#show"
  match "/login", "sessions#new"
  match "/project/:publicKey", "projects#show"
