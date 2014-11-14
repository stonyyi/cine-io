/** @jsx React.DOM */
var React = require('react'),
  authentication = Cine.lib('authentication'),
  cx = Cine.lib('cx'),
  _ = require('underscore');
module.exports = React.createClass({
  mixins: [Cine.lib('requires_app')],
  getInitialState: function(){
    return {linksMoved: false};
  },
  _createLogoutSuccess: function(){
    var ca = this.props.app.currentAccount();
    if (ca.isAppdirect()){
      var logoutUrl = ca.get('appdirect').baseUrl + '/applogout?openid=' + this.props.app.currentUser.get('appdirectUUID');
      return function(){
        window.location = logoutUrl;
      }
    }else{
      self = this;
      return function(){
        self.props.app.router.redirectTo('/');
      }
    }
  },
  logout: function(e) {
    e.preventDefault();
    var _this = this
      , app = this.props.app
      , options = {
          success: this._createLogoutSuccess()
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
  toggleLinksMoved: function(e){
    e.preventDefault();
    this.setState({linksMoved: !this.state.linksMoved});
  },
  render: function() {
    var
      self = this,
      name = this.props.app.currentUser.get('name'),
      currentAccount = this.props.app.currentAccount(),
      accounts = this.props.app.currentUser.accounts(),
      accountDropDown, additionalListItems;
    if (accounts.length > 1){
      var accountList = accounts.map(function(account) {
        var internal;
        if (account === currentAccount){
          internal = (<a href="" className='current' onClick={self.doNothing}>{account.displayName()}</a>);
        }else{
          internal = (<a href="" onClick={self.changeAccount.bind(self, account)}>{account.displayName()}</a>);
        }
        return (
          <li key={account.get('id')}>
            {internal}
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
    }

    if (currentAccount && currentAccount.isAppdirect()){
      var
        billingUrl = currentAccount.get('appdirect').baseUrl+"/account/apps/",
        userUrl = currentAccount.get('appdirect').baseUrl+"/account/assign/";
      additionalListItems = [(
        <li><a href={billingUrl} target="_blank">Billing Information</a></li>
      ), (
        <li><a href={userUrl} target="_blank">User Management</a></li>
      )];
    }
    var linksClass = cx({'has-dropdown': true, 'not-click': true, moved: this.state.linksMoved});
    return (
      <section className="top-bar-section">
        <ul className="right account-drop-down">
          {accountDropDown}
          <li ref="links" className={linksClass}>
            <a href="" onClick={this.toggleLinksMoved}>{name}</a>
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
