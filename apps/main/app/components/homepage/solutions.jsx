/** @jsx React.DOM */
var React = require('react'),
PageWrapper = Cine.component('layout/_page_wrapper');

module.exports = React.createClass({
  displayName: 'HomepageSolutions',
  mixins: [Cine.lib('requires_app')],

  render: function() {

    return (
      <PageWrapper selected='solutions' fixedNav={true} app={this.props.app}>
      </PageWrapper>
    );
  }
});
