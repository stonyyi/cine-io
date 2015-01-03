exports.componentDidMount = ->
  @props.app.currentUser.on('login', @redirectToDashboard)
exports.componentWillUnmount = ->
  @props.app.currentUser.off('login', @redirectToDashboard)
exports.redirectToDashboard = ->
  @props.app.router.redirectTo('/dashboard')
