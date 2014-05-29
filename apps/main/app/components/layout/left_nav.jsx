/** @jsx React.DOM */
var React = require('react'),
authentication = Cine.lib('authentication');

var GithubLogin = React.createClass({
  displayName: 'GithubLogin',
  mixins: [Cine.lib('requires_app')],
  githubLogin: function(e){
    e.preventDefault();
    var
      app = this.props.app,
      button = jQuery(e.currentTarget);
    authentication.githubLogin(app, button);
  },
  render: function() {
    return (
      <a className='button github-login' href='/auth/github'>
        <i className="fa fa-github"></i>
        <span className="btn-social-text">Sign in with Github</span>
      </a>
    );
  }
});

var EmailLogin = React.createClass({
  displayName: 'EmailLogin',
  mixins: [Cine.lib('requires_app')],
  propTypes: {
    showing: React.PropTypes.bool.isRequired
  },
  getInitialState: function() {
    return {allowFocusHijack: true, completeSignup: false, myName: '', myPassword: '', myEmail: ''};
  },
  submitName: function (e){
    e.preventDefault();
    var
      _this = this,
      app = this.props.app,
      form = jQuery(e.currentTarget),
      options = {completeSignup: this.completeSignup};
    authentication.updateAccount(app, form, options);
  },
  emailLogin: function (e){
    e.preventDefault();
    var
      _this = this,
      app = this.props.app,
      form = jQuery(e.currentTarget),
      options = {completeSignup: this.completeSignup};

    authentication.login(app, form, options);
  },
  completeSignup: function(){
    this.setState({allowFocusHijack: true, completeSignup: true});
  },
  changeMyName: function(event) {
    this.setState({myName: event.target.value});
  },
  changeMyEmail: function(event) {
    this.setState({myEmail: event.target.value});
  },
  changeMyPassword: function(event) {
    this.setState({myPassword: event.target.value});
  },
  componentWillReceiveProps: function(nextProps){
    // allow the focus to be hijacked when not showing
    if (!nextProps.showing){
      this.setState({allowFocusHijack: true});
      return;
    }
    // if we just focused do not allow it to be hijacked
    if (!this.state.allowFocusHijack){
      return;
    }
    // we're about to focus, prevent an additional hijack from state change.
    this.setState({allowFocusHijack: false});
    this.focusProperInput();
  },
  focusProperInput: function(){
    var ref;
    if (this.state.completeSignup) {
      ref = 'nameField';
    }else{
     ref = 'emailField';
    }
    this.refs[ref].getDOMNode().focus();
  },
  render: function() {
    var suffix = '';
    if (this.state.myName.length > 0){
      suffix = ', '+this.state.myName;
    }
    if (this.state.completeSignup){
      return (
        <form onSubmit={this.submitName}>
          <p>Welcome to cine.io{suffix}.</p>
          <input name='name' type="text" required placeholder='Your Name' ref='nameField' value={this.state.myName} onChange={this.changeMyName}/>
          <button>Join</button>
        </form>
      );
    } else{
      return (
        <form onSubmit={this.emailLogin}>
          <input name='username' type="email" required placeholder='Your email' ref='emailField' value={this.state.myEmail} onChange={this.changeMyEmail}/>
          <input name='password' type="password" required placeholder='Your password' value={this.state.myPassword} onChange={this.changeMyPassword}/>
          <button>Log in</button>
        </form>
      );
    }
  }
});


LoggedOut = React.createClass({
  displayName: 'LoggedOut',
  mixins: [Cine.lib('requires_app')],
  propTypes: {
    showing: React.PropTypes.bool.isRequired
  },
  closeNav: function(e){
    e.preventDefault();
    this._owner.closeNav();
  },
  render: function() {
    return (
      <aside className="left-off-canvas-menu">
        <div className='clearfix'>
          <a className='right' href='' onClick={this.closeNav}>
            <i className="fa fa-times"></i>
          </a>
        </div>
        <GithubLogin app={this.props.app}/>
        <EmailLogin app={this.props.app} showing={this.props.showing} />
      </aside>
    );
  }
});


module.exports = React.createClass({
  displayName: 'LeftNav',
  mixins: [Cine.lib('requires_app')],
  propTypes: {
    showing: React.PropTypes.bool.isRequired
  },
  closeNav: function(){
    this._owner.closeNav()
  },
  render: function() {
    if (this.props.app.currentUser.isLoggedIn()) {
      return (
        <aside className="left-off-canvas-menu">
          <ul>
            <li>You are logged in.</li>
          </ul>
        </aside>
      );
    }else{
      return (
        <LoggedOut app={this.props.app} showing={this.props.showing}/>
      );
    }
  }
});
