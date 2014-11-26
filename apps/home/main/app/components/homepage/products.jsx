/** @jsx React.DOM */
var React = require('react'),
Libraries = Cine.component('homepage/_libraries'),
PageWrapper = Cine.component('layout/_page_wrapper');

module.exports = React.createClass({
  displayName: 'HomepageProducts',
  mixins: [Cine.lib('requires_app')],

  render: function() {

    return (
      <PageWrapper selected='products' fixedNav={true} app={this.props.app}>
      </PageWrapper>
    );
  }
});
