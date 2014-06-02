cx = Cine.lib('cx');

exports.getInitialState = ->
  return {showingLeftNav: false}

exports.componentDidMount = ->
  @props.app.currentUser.on('login', @closeNav, this);
  @props.app.currentUser.on('logout', @closeNav, this);
  @props.app.on('show-login', @openNav, this);
  @props.app.on('hide-login', @closeNav, this);

exports.componentWillUnMount = ->
  @props.app.currentUser.off('login', @closeNav);
  @props.app.currentUser.off('logout', @closeNav);
  @props.app.off('show-login', @openNav);
  @props.app.off('hide-login', @closeNav);

exports.closeNav = ->
  @setState(showingLeftNav: false)

exports.openNav = ->
  @setState(showingLeftNav: true)

exports.toggleLeftNav = (e)->
  e.preventDefault()
  @setState(showingLeftNav: !@state.showingLeftNav)

exports.canvasClasses = ->
  cx('off-canvas-wrap': true, 'move-right': @state.showingLeftNav)
