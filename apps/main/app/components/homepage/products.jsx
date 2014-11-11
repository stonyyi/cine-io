/** @jsx React.DOM */
var React = require('react'),
PageWrapper = Cine.component('layout/_page_wrapper');

module.exports = React.createClass({
  displayName: 'HomepageProducts',
  mixins: [Cine.lib('requires_app')],

  render: function() {

    return (
      <PageWrapper selected='products' app={this.props.app}>
        <h1>I am products</h1>
      </PageWrapper>
    );
  }
});
