/** @jsx React.DOM */
var React = require('react'),
Pricing = Cine.component('homepage/_pricing'),
PageWrapper = Cine.component('layout/_page_wrapper');

module.exports = React.createClass({
  displayName: 'HomepagePricing',
  mixins: [Cine.lib('requires_app')],

  render: function() {

    return (
      <PageWrapper selected='pricing' fixedNav={true} app={this.props.app} wide="true">
        <Pricing app={this.props.app} />
      </PageWrapper>
    );
  }
});