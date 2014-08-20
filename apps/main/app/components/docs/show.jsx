/** @jsx React.DOM */
var React = require('react'),
PageWrapper = Cine.component('layout/_page_wrapper'),
Static = Cine.component('shared/_static');

module.exports = React.createClass({
  displayName: 'DocsShow',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin')],
  getBackboneObjects: function(){
    return this.props.model;
  },
  componentDidMount: function(){
    Prism.highlightAll();
  },
  componentDidUpdate: function(){
    Prism.highlightAll();
  },
  render: function() {
    return (
      <PageWrapper app={this.props.app}>
        <Static document={this.props.model.get('document')} />
      </PageWrapper>
    );
  }
});
