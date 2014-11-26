/** @jsx React.DOM */
var React = require('react'),
  User = Cine.model('user'),
  SubmitButton = Cine.component('shared/_submit_button'),
  authentication = Cine.lib('authentication');

module.exports = React.createClass({
  displayName: 'AccountForm',
  mixins: [Cine.lib('requires_app')],
  getInitialState: function(){
    var currentUser = this.props.app.currentUser;
    return {name: currentUser.get('name'), email: currentUser.get('email'), submitting: false};
  },
  changeName: function(event) {
    this.setState({name: event.target.value});
  },
  changeEmail: function(event) {
    this.setState({email: event.target.value});
  },
  updateUser: function(event){
    event.preventDefault();
    if(this.state.submitting){return;}
    this.setState({submitting: true});
    var
      self = this,
      form = jQuery(event.currentTarget);
    options = {
      success: function(){
        if (self.isMounted()){ self.setState({submitting: false}); }
      },
      error: function(){
        if (self.isMounted()){ self.setState({submitting: false}); }
      }
    }
    authentication.updateAccount(this.props.app, form, options);
  },
  render: function() {
    return (
      <form onSubmit={this.updateUser}>
        <div className="row">
          <div className="large-12 columns">
            <label>Name
              <input type="text" placeholder="Your name" value={this.state.name} onChange={this.changeName} name='name'/>
            </label>
          </div>
        </div>
        <div className="row">
          <div className="large-12 columns">
            <label>Email
              <input type="text" placeholder="Your email" value={this.state.email} onChange={this.changeEmail} name='email'/>
            </label>
          </div>
        </div>
        <div className="row">
          <div className="large-12 columns">
            <SubmitButton text="Save" submittingText="Saving" submitting={this.state.submitting}/>
          </div>
        </div>
      </form>
    );
  }
});
