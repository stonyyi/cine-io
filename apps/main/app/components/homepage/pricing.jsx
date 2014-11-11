/** @jsx React.DOM */
var React = require('react'),
PageWrapper = Cine.component('layout/_page_wrapper');

module.exports = React.createClass({
  displayName: 'HomepagePricing',
  mixins: [Cine.lib('requires_app')],

  render: function() {

    return (
      <PageWrapper selected='pricing' app={this.props.app}>
        <h1>I am pricing</h1>
      </PageWrapper>
    );
  }
});
