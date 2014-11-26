/** @jsx React.DOM */
var
  React = require('react'),
  PageWrapper = Cine.component('layout/_page_wrapper'),
  parseUri = Cine.lib('parse_uri')
;

module.exports = React.createClass({
  displayName: 'ComponentsShow',
  mixins: [Cine.lib('requires_app')],
  render: function() {
    var Component = Cine.component(this.props.options.component);
    return (
      <PageWrapper app={this.props.app}>
        <Component app={this.props.app} />
      </PageWrapper>
    )
  }
});
