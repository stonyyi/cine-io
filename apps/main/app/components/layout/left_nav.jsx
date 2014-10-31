/** @jsx React.DOM */
var React = require('react'),
  SubmitButton = Cine.component('shared/_submit_button'),
  authentication = Cine.lib('authentication');

var GithubLogin = React.createClass({
  displayName: 'GithubLogin',
  mixins: [Cine.lib('requires_app')],
  getInitialState: function() {
    return {plan: 'free'};
  },
  componentDidMount: function(){
    this.props.app.on('set-signup-plan', this.setPlan, this);
  },
  componentWillUnmount: function(){
    this.props.app.off('set-signup-plan', this.setPlan);
  },
  setPlan: function(plan){
    this.setState({plan: plan});
  },
  render: function() {
    var url = "/auth/github?client=web&plan="+this.state.plan;
    return (
      <a className='button expand radius button-social button-github github-login' href={url}>
        <i className="fa fa-github"></i>
        <span className="button-social-text">Sign in with Github</span>
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
    return {allowFocusHijack: true, completeSignup: false, myName: '', myPassword: '', myEmail: '', plan: 'free', submitting: false};
  },
  componentDidMount: function(){
    this.props.app.on('set-signup-plan', this.setPlan, this);
  },
  componentWillUnmount: function(){
    this.props.app.off('set-signup-plan', this.setPlan);
  },
  setPlan: function(plan){
    this.setState({plan: plan});
  },
  submitName: function (e){
    e.preventDefault();
    if (this.state.submitting){return;}
    var
      _this = this,
      app = this.props.app,
      form = jQuery(e.currentTarget),
      options = {completeSignup: this.completeSignup};
    this.setState({submitting: true});
    authentication.updateAccount(app, form, options);
  },
  loginError: function (message){
    this.props.app.flash(message, 'alert');
    this.setState({submitting: false});
  },
  emailLogin: function (e){
    e.preventDefault();
    if (this.state.submitting){return;}
    var
      _this = this,
      app = this.props.app,
      form = jQuery(e.currentTarget),
      options = {completeSignup: this.completeSignup, error: this.loginError};
    this.setState({submitting: true});
    authentication.login(app, form, options);
  },
  completeSignup: function(){
    this.setState({allowFocusHijack: true, completeSignup: true, submitting: false});
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
  componentDidUpdate: function(){
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
  showForgotPassword: function(e){
    e.preventDefault();
    this.setState({forgotPassword: true, completeSignup: false, submitting: false});
    this.focusProperInput();
  },
  hideForgotPassword: function(e){
    e.preventDefault();
    this.setState({forgotPassword: false, completeSignup: false, submitting: false});
    this.focusProperInput();
  },
  sendForgotPassword: function(e){
    e.preventDefault();
    if (this.state.submitting){return;}
    this.setState({submitting: true});
    var self = this;
    authentication.forgotPassword(this.props.app, jQuery(e.currentTarget), {
      success: function(){
        self.setState({forgotPassword: false, completeSignup: false, submitting: false});
        self.props.app.flash("A password recovery email was sent to "+self.state.myEmail+".", 'info');
      },
      error: function(){
        self.setState({submitting: false});
      }
    });
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
          <input name='completedsignup' type="hidden" value="local" />
          <input name='name' type="text" required placeholder='Your Name' ref='nameField' value={this.state.myName} onChange={this.changeMyName}/>
          <SubmitButton className="button radius expand" text="Join" submittingText="Joining" submitting={this.state.submitting}/>
        </form>
      );
    } else if (this.state.forgotPassword){
      return (
        <form onSubmit={this.sendForgotPassword}>
          <input name='email' type="email" required placeholder='Your email' ref='emailField' value={this.state.myEmail} onChange={this.changeMyEmail}/>
          <SubmitButton className="button radius expand bottom-margin-0" text="Recover Password" submittingText="Recovering" submitting={this.state.submitting}/>
          <div className='text-center top-margin-half'>
            <a href='' onClick={this.hideForgotPassword}>I remember my password.</a>
          </div>
        </form>
      );
    } else{
      return (
        <form onSubmit={this.emailLogin}>
          <input name='username' type="email" required placeholder='Your email' ref='emailField' value={this.state.myEmail} onChange={this.changeMyEmail}/>
          <input name='password' type="password" required placeholder='Your password' value={this.state.myPassword} onChange={this.changeMyPassword}/>
          <input name='plan' type="hidden" required value={this.state.plan}/>
          <SubmitButton className="button radius expand bottom-margin-0" text="Sign up or sign in" submittingText="Submitting" submitting={this.state.submitting}/>
          <div className='text-center top-margin-half'>
            <a href='' onClick={this.showForgotPassword}>Forgot password?</a>
          </div>
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
    this.props.app.trigger('hide-login');
  },
  render: function() {
    return (
      <aside className="left-off-canvas-menu">
        <div className='clearfix'>
          <a className='close-link right' href='' onClick={this.closeNav}>
            <i className="fa fa-times"></i>
          </a>
        </div>
        <GithubLogin app={this.props.app}/>
        <EmailLogin app={this.props.app} showing={this.props.showing} />
        <div className='legal-waver top-margin-half'>
          By using this site you are agreeing to our <a href='/legal/terms-of-service'>Terms of Service</a>.
        </div>
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
    this.props.app.trigger('hide-login');
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
