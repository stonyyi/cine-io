module.exports = (match) ->
  match "/", "homepage#show"
  match "/pricing", "homepage#pricing"

  match "/products/:id", "products#show"
  match "/solutions/:id", "solutions#show"

  # errors
  match '/401',        'errors#unauthorized'
  match '/404',        'errors#not_found'
  match '/500',        'errors#server_error'

  match "/dashboard", "dashboard#show"
  match "/profile", "profile#edit"
  match "/usage", "usage_reports#show"
  match "/account", "account#show"
  # For some reason this doesn't work.
  # match '/legal(/:id)', 'legal#show'
  match '/legal', 'legal#show'
  match '/legal/:id', 'legal#show'

  match '/recover-password/:identifier', 'password_change_requests#show'

  match '/component', 'components#show'
