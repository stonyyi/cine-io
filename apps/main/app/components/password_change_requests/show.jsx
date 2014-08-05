/** @jsx React.DOM */
var React = require('react'),
PageWrapper = Cine.component('layout/_page_wrapper'),
authentication = Cine.lib('authentication');

module.exports = React.createClass({
  displayName: 'PasswordChangeRequestsShow',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin'), Cine.lib('has_nav')],
  getBackboneObjects: function(){
    return this.props.model;
  },
  setNewPassword: function(e){
    e.preventDefault();
    var self = this;
    authentication.updatePassword(this.props.app, jQuery(e.currentTarget));
  },
  componentDidMount: function(){
    this.refs.newPassword.getDOMNode().focus();
  },
  render: function() {
    return (
      <PageWrapper app={this.props.app}>
        <div className='row'>
          <div className='small-12 columns'>
            <h1>Create a new password</h1>
          </div>
        </div>
        <form onSubmit={this.setNewPassword} className='top-margin-1'>
          <input type='hidden' name='identifier' value={this.props.model.get('identifier')} />
          <div className="row">
            <div className="small-3 columns">
              <label htmlForm="new-password" className="right inline">New Password</label>
            </div>
            <div className="small-9 columns">
              <input ref='newPassword' type="password" name='password' required="required" id="new-password" placeholder="Create a new password" />
            </div>
          </div>
          <div className="row">
            <div className="small-8 small-offset-3 columns">
              <button type="submit" className="btn btn-primary btn-block" data-loading-text="Changing...">Change Password</button>
            </div>
          </div>
        </form>
      </PageWrapper>
    );
  }
});
