/** @jsx React.DOM */
var React = require('react'),
PageWrapper = Cine.component('layout/_page_wrapper');

module.exports = React.createClass({
  displayName: 'ErrorsNotFound',
  mixins: [Cine.lib('requires_app')],
  render: function() {
    return (
      <PageWrapper app={this.props.app}>
        <div className="row">
          <div className="large-12 columns">
            <h1>Not found</h1>
            <p>Sorry we could not find that resource.</p>
          </div>
        </div>
      </PageWrapper>
    );
  }
});
