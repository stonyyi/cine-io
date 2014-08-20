/** @jsx React.DOM */
var React = require('react'),
  authentication = Cine.lib('authentication'),
  capitalize = Cine.lib('capitalize');

module.exports = React.createClass({
  mixins: [Cine.lib('requires_app')],

  logout: function(e) {
    e.preventDefault();
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
    var
      name = this.props.app.currentUser.get('name'),
      plan = this.props.app.currentAccount().get('tempPlan');

    return (
      <section className="top-bar-section">
        <ul className="right">
          <li className='has-form'>
            <span className='plan-name'>{capitalize(plan)}</span>
          </li>
          <li className="has-dropdown not-click">
            <a href="" onClick={this.doNothing}>{name}</a>
            <ul className="dropdown">
              <li><a href='/'>Home</a></li>
              <li><a href='/account'>Account</a></li>
              <li><a href='/usage'>Usage</a></li>
              <li><a href='/billing'>Billing</a></li>
              <li><a href='' onClick={this.logout}>Sign Out</a></li>
            </ul>
          </li>
          <li className="menu-icon"><a href="#"></a></li>
        </ul>
      </section>
    );
  }
});
