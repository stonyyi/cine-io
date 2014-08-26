exports.getInitialState = ->
  return {showingModal: false}

exports.componentDidMount = ->
  @props.app.on('show-modal', @showModal, this)
  @props.app.on('hide-modal', @hideModal, this)

exports.componentWillUnmount = ->
  @props.app.off('show-modal', @showModal)
  @props.app.off('hide-modal', @hideModal)

exports.hideModal = (e)->
  e.preventDefault() if e
  return unless @isMounted()
  $('body').off('keydown', @_keydownListener)
  @setState(showingModal: false, modalCompnent: undefined)

exports.showModal = (componentName)->
  return unless @isMounted()
  $('body').on('keydown', @_keydownListener)
  @setState(showingModal: true, modalCompnent: componentName)

exports._keydownListener = (e)->
  @hideModal() if (e.which==27)
