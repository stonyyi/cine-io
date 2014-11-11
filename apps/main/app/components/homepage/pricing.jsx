/** @jsx React.DOM */
var React = require('react'),
Pricing = Cine.component('homepage/_pricing'),
PageWrapper = Cine.component('layout/_page_wrapper');

module.exports = React.createClass({
  displayName: 'HomepagePricing',
  mixins: [Cine.lib('requires_app')],

  render: function() {

    return (
      <PageWrapper selected='pricing' app={this.props.app}>
        <Pricing app={this.props.app} />
      </PageWrapper>
    );
  }
});
