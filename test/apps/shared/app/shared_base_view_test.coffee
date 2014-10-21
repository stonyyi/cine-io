SharedBaseView = Cine.arch('shared_base_view')
React = require("react")

describe 'SharedBaseView', ->

  fakeComponent = React.createClass
    displayName: 'HomepageShow'
    render: ->
      someAttributeOnTheApp = @props.app.constructor.flashEvent
      React.DOM.div(null, "The #{@props.model}-#{@props.collection}-#{@props.options.otherOption}-#{someAttributeOnTheApp}")
  beforeEach ->
    @componentStub = sinon.stub(Cine, 'component').returns(fakeComponent)

  afterEach ->
    @componentStub.restore()

  beforeEach ->
    @viewClass = SharedBaseView('fake/view')
    @view = new @viewClass
      collection: 'some collection'
      model: 'some model'
      otherOption: 'other option'
      app: mainApp
  describe 'creating a dynamic react view', ->

    it 'assigns an id', ->
      expect(@viewClass.id).to.equal('fake/view')

    it 'assigns a class', ->
      expect(@view.className).to.equal('fake-view')

    it 'assigns a component', ->
      expect(@view.Component).to.equal(fakeComponent)

  describe 'including options to render', ->
    it 'includes the collection', ->
      expect(@view.getInnerHtml()).to.match(/-some collection-/)
    it 'includes the model', ->
      expect(@view.getInnerHtml()).to.match(/The some model/)
    it 'includes the options', ->
      expect(@view.getInnerHtml()).to.match(/-other option/)
    it 'includes the app', ->
      expect(@view.getInnerHtml()).to.match(/-flash-message/)

  describe 'rendering server side', ->
    it 'renders to string', ->
      expect(@view.getInnerHtml()).to.match(/<div.+>.+<\/div>/)
  describe 'rendering client side', ->
    beforeEach ->
      @renderStub = sinon.stub(React, 'renderComponent').returns("I rendered")
    afterEach ->
      @renderStub.restore()

    isRenderedReactComponent = (component)->
      component.__realComponentInstance?

    it 'renders the component', ->
      expect(@view.postRender()).to.equal("I rendered")

    it 'passed the correct arguments', ->
      @view.el = "some dom element"
      @view.postRender()
      expect(@renderStub.calledOnce).to.be.true
      args = @renderStub.firstCall.args
      expect(args).to.have.length(2)
      expect(isRenderedReactComponent(args[0])).to.be.true
      expect(args[1]).to.equal("some dom element")
