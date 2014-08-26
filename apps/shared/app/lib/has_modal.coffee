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
  @setState(showingModal: false, modalCompnent: undefined) if @isMounted()

exports.showModal = (componentName)->
  @setState(showingModal: true, modalCompnent: componentName) if @isMounted()
