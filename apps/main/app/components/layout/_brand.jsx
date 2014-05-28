/** @jsx React.DOM */
var React = require('react')
  , authentication = Cine.lib('authentication');

module.exports = React.createClass({
  goHome: function() {
    this.props.app.router.redirectTo('/');
  },

  render: function() {
    return (
      <ul className="title-area">
        <li className="name">
          <h1><a onClick={this.goHome}>cine.io</a></h1>
        </li>
        <li className="toggle-topbar menu-icon"><a href=""></a></li>
      </ul>
    );
  }
});
