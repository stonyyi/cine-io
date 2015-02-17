/** @jsx React.DOM */
var React = require('react')
  , authentication = Cine.lib('authentication');

module.exports = React.createClass({
  mixins: [Cine.lib('requires_app')],
  propTypes: {
    toggleExpandMenu: React.PropTypes.func.isRequired,
    location: React.PropTypes.string
  },
  render: function() {
    return (
      <ul className="title-area">
        <li className="name">
          <h1 className="brand"><a href={this.props.location || '/'}>cine.io</a></h1>
        </li>
        <li className="toggle-topbar menu-icon account-drop-down">
          <a href="" onClick={this.props.toggleExpandMenu}>
            <i className="fa fa-bars"></i>
          </a>
        </li>
      </ul>
    );
  }
});
