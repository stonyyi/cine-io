/** @jsx React.DOM */
var React = require('react')
  , authentication = Cine.lib('authentication');

module.exports = React.createClass({
  mixins: [Cine.lib('requires_app')],

  goHome: function() {
    this.props.app.router.redirectTo('/');
  },

  render: function() {
    return (
      <ul className="title-area">
        <li className="name">
          <h1 className="brand"><a onClick={this.goHome}>cine.io</a></h1>
        </li>
        <li className="toggle-topbar menu-icon"><a href=""></a></li>
      </ul>
    );
  }
});
