/** @jsx React.DOM */
var React = require('react'),
  User = Cine.model('user'),
  _ = require('underscore'),
  authentication = Cine.lib('authentication');

module.exports = React.createClass({
  displayName: 'AccountForm',
  mixins: [Cine.lib('requires_app')],
  getInitialState: function(){
    var currentUser = this.props.app.currentUser;
    return {name: currentUser.get('name'), email: currentUser.get('email'), plan: currentUser.get('plan')};
  },
  changeName: function(event) {
    this.setState({name: event.target.value});
  },
  changeEmail: function(event) {
    this.setState({email: event.target.value});
  },
  changePlan: function(event) {
    this.setState({plan: event.target.value});
  },
  updateAccount: function(event){
    event.preventDefault();
    var form = jQuery(event.currentTarget);
    authentication.updateAccount(this.props.app, form);
  },
  render: function() {
    var planOptions = _.map(User.plans, function(plan) {
      var capitalized = plan.charAt(0).toUpperCase() + plan.slice(1);
      return (<option key={plan} value={plan}>{capitalized}</option>);
    });
    return (
      <form onSubmit={this.updateAccount}>
        <div className="row">
          <div className="large-12 columns">
            <label>Name
              <input type="text" placeholder="Your name" value={this.state.name} onChange={this.changeName} name='name'/>
            </label>
          </div>
        </div>
        <div class="row">
          <div className="large-12 columns">
            <label>Email
              <input type="text" placeholder="Your email" value={this.state.email} onChange={this.changeEmail} name='email'/>
            </label>
          </div>
        </div>
        <div class="row">
          <div className="large-12 columns">
            <label>Plan
              <select value={this.state.projectPlan} onChange={this.changeProjectPlan} name='plan'>
                {planOptions}
              </select>
            </label>
          </div>
        </div>
        <div class="row">
          <div className="large-12 columns">
            <button type='submit'>Save</button>
          </div>
        </div>
      </form>
    );
  }
});