/** @jsx React.DOM */
var React = require('react');
authentication = Cine.lib('authentication');

module.exports = React.createClass({
  logout: function(){
    var
      _this = this,
      app = this.props.app,
      options = {success: function(){
        _this.props.app.router.redirectTo('/');
      }};

    authentication.logout(app, options);

  },
  render: function() {
    return (
      <header>
        <div className="row">
          <div className="info">This is the header.</div>
          <a className="info" onClick={this.logout}>Logout</a>
        </div>
      </header>
    );
  }
});
