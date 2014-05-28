/** @jsx React.DOM */
var React = require('react');
Footer = Cine.component('layout/footer');
authentication = Cine.lib('authentication');
module.exports = React.createClass({
  displayName: 'SessionsNew',
  mixins: [Cine.lib('requires_app')],
  emailLogin: function (e){
    e.preventDefault();
    var
      _this = this,
      app = this.props.app,
      form = jQuery(e.currentTarget),
      options = {success: function(){
        _this.props.app.router.redirectTo('/');
      }};

    authentication.login(app, form, options);
  },
  githubLogin: function(e){
    e.preventDefault();
    var
      app = this.props.app,
      button = jQuery(e.currentTarget);
    authentication.githubLogin(app, button);
  },

  render: function() {
    return (
      <div id='login'>
        <a className='button github-login' href='/auth/github'>
          <i className="fa fa-github"></i>
          <span className="btn-social-text">Sign in with Github</span>
        </a>
        <form onSubmit={this.emailLogin}>
          <input name='username' type="email" placeholder='Your email' />
          <input name='password' type="password" placeholder='Your password' />
          <button>Log in</button>
        </form>
        <Footer/>
      </div>
    );
  }
});
