/** @jsx React.DOM */
var React = require('react'),
  authentication = Cine.lib('authentication'),
  _ = require('underscore');
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
  changeAccount: function(account, e){
    e.preventDefault();
    this.props.app.changeAccount(account);
  },
  render: function() {
    var
      self = this,
      name = this.props.app.currentUser.get('name'),
      currentAccount = this.props.app.currentAccount(),
      accounts = this.props.app.currentUser.accounts(),
      accountDropDown, additionalListItems;
    if (accounts.length > 1){
      var accountList =  _.map(accounts.without(currentAccount), function(account) {
        return (
          <li key={account.get('id')}>
            <a href="" onClick={self.changeAccount.bind(self, account)}>{account.displayName()}</a>
          </li>
        );
      });

      accountDropDown = (
        <li className="has-dropdown not-click">
          <a href="" onClick={this.doNothing}>{currentAccount.displayName()}</a>
          <ul className="dropdown">
            {accountList}
          </ul>
        </li>
      );
    }else{
      accountDropDown = (
        <li className='has-form'>
          <span className='plan-name'>{currentAccount.displayName()}</span>
        </li>
      );
    }

    if (currentAccount.isAppdirect()){
      var
        billingUrl = currentAccount.get('appdirect').baseUrl+"/account/apps/",
        userUrl = currentAccount.get('appdirect').baseUrl+"/account/assign/";
      additionalListItems = [(
        <li><a href={billingUrl} target="_blank">Billing Information</a></li>
      ), (
        <li><a href={userUrl} target="_blank">User Management</a></li>
      )];
    }

    return (
      <section className="top-bar-section">
        <ul className="right">
          {accountDropDown}
          <li className="has-dropdown not-click">
            <a href="" onClick={this.doNothing}>{name}</a>
            <ul className="dropdown">
              <li><a href='/'>Home</a></li>
              {additionalListItems}
              <li><a href='/profile'>Profile</a></li>
              <li><a href='/account'>Account</a></li>
              <li><a href='/usage'>Usage</a></li>
              <li><a href='' onClick={this.logout}>Sign Out</a></li>
            </ul>
          </li>
          <li className="menu-icon"><a href="#"></a></li>
        </ul>
      </section>
    );
  }
});
