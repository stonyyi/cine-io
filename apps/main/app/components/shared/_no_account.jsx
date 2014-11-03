/** @jsx React.DOM */
var
  React = require('react'),
  PageWrapper = Cine.component('layout/_page_wrapper');

module.exports = React.createClass({
  displayName: 'NoAccount',
  mixins: [Cine.lib('requires_app')],
  render: function() {
    return (
      <PageWrapper app={this.props.app}>
        <h1>You do not have any accounts.</h1>
      </PageWrapper>
    );
  }
});
