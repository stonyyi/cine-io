/** @jsx React.DOM */
var React = require('react')
  , authentication = Cine.lib('authentication');

module.exports = React.createClass({
  mixins: [Cine.lib('requires_app')],

  logout: function() {
    var _this = this
      , app = this.props.app
      , options = {
          success: function() {
            _this.props.app.router.redirectTo('/');
          }
        };
    authentication.logout(app, options);
  },
  doNothing: function(e){
    e.preventDefault();
  },
  render: function() {
    var name = this.props.app.currentUser.get('name');

    return (
      <section className="top-bar-section">
        <ul className="right">
          <li className="has-dropdown not-click">
            <a href="" onClick={this.doNothing}>{name}</a>
            <ul className="dropdown">
              <li><a onClick={this.logout}>Sign Out</a></li>
            </ul>
          </li>
          <li className="menu-icon"><a href="#"></a></li>
        </ul>
      </section>
    );
  }
});