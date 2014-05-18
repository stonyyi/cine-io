/** @jsx React.DOM */
var React = require('react');
authentication = Cine.lib('authentication');

module.exports = React.createClass({
  mixins: [Cine.lib('backbone_mixin')],
  logout: function(){
    var
      _this = this,
      app = this.props.app,
      options = {success: function(){
        _this.props.app.router.redirectTo('/');
      }};

    authentication.logout(app, options);

  },
  getBackboneObjects: function(){
    return this.props.app.currentUser;
  },

  render: function() {
    var name = this.props.app.currentUser.get('name');
    return (
      <header>
        <div className="panel clearfix">
          <div className='right'>
            <span> Hello {name}! </span>
            <a className="info" onClick={this.logout}>Logout</a>
          </div>
        </div>
      </header>
    );
  }
});
