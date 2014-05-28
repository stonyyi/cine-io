/** @jsx React.DOM */
var React = require('react')
  , authentication = Cine.lib('authentication');

module.exports = React.createClass({
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

  render: function() {
    var name = this.props.app.currentUser.get('name');

    return (
      <section className="top-bar-section">
        <ul className="right show-for-large-up">
          <li className="has-dropdown not-click">
            <a href="#">{name}</a>
            <ul className="dropdown">
              <li><a onClick={this.logout}>Sign Out</a></li>
            </ul>
          </li>
        </ul>
      </section>
    );
  }
});
