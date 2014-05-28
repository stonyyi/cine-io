/** @jsx React.DOM */
var React = require('react');

module.exports = React.createClass({
  render: function() {
    return (
      <div className="static-document" dangerouslySetInnerHTML={{__html: this.props.document}} />
    );
  }
});
