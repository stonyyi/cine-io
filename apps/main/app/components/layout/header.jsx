/** @jsx React.DOM */
var React = require('react')
  , LoggedIn = Cine.component('layout/_logged_in')
  , LoggedOut = Cine.component('layout/_logged_out')
  , Brand = Cine.component('layout/_brand');

module.exports = React.createClass({
  displayName: 'Header',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin')],
  getBackboneObjects: function(){
    return this.props.app.currentUser;
  },

  render: function() {
    if (this.props.app.currentUser.isLoggedIn()) {
      return (
        <header>
          <nav className="top-bar" data-options="is_hover: false" data-topbar>
            <Brand app={this.props.app} />
            <LoggedIn app={this.props.app} />
          </nav>
        </header>
      );
    } else {
      return (
        <header>
          <nav className="top-bar" data-options="is_hover: false" data-topbar>
            <Brand app={this.props.app} />
            <LoggedOut app={this.props.app} />
          </nav>
        </header>
      );
    }
  }
});
