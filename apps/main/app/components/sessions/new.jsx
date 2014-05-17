/** @jsx React.DOM */
var React = require('react');
Footer = Cine.component('layout/footer');
authentication = Cine.lib('authentication');
module.exports = React.createClass({
  onSubmit: function (e){
    e.preventDefault();
    var
      _this = this,
      app = this.props.app,
      form = this.props.jQuery(e.currentTarget),
      options = {success: function(){
        _this.props.app.router.redirectTo('/');
      }};

    authentication.login(app, form, options);
  },

  render: function() {
    return (
      <div id='login'>
        <form onSubmit={this.onSubmit}>
          <input name='username' type="email" placeholder='Your email' />
          <input name='password' type="password" placeholder='Your password' />
          <button>Log in</button>
        </form>
        <Footer/>
      </div>
    );
  }
});
