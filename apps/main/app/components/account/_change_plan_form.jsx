/** @jsx React.DOM */
var React = require('react'),
PageWrapper = Cine.component('layout/_page_wrapper'),
  Account = Cine.model('account'),
  _ = require('underscore'),
  capitalize = Cine.lib('capitalize');

module.exports = React.createClass({
  displayName: 'ChangePlanForm',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin')],
  getBackboneObjects: function(){
    return this.props.app.currentAccount();
  },
  getInitialState: function(){
    var currentAccount = this.props.app.currentAccount();
    return {tempPlan: currentAccount.get('tempPlan'), initialTempPlan: currentAccount.get('tempPlan')};
  },
  changePlan: function(event) {
    this.setState({tempPlan: event.target.value});
  },
  updateSuccess: function(){
    if (this.state.plan != this.state.initialPlan){
      this.props.app.tracker.planChange(this.state.plan);
      this.setState({initialPlan: this.state.plan});
    }
  },
  updateAccount: function(e){
    e.preventDefault();
    var self = this;
      ca = self.props.app.currentAccount();
    ca.set({tempPlan: this.state.tempPlan})
    ca.save(null,{
      success: function(model, response, options){
        self.updateSuccess()
        model.store();
        self.props.app.flash('Successfully updated plan.', 'success');
      },
      error: function(model, response, options){
      }
    });
  },
  render: function() {
    var planOptions = _.map(Account.plans, function(plan) {
      return (<option key={plan} value={plan}>{capitalize(plan)}</option>);
    });

    return (
      <form onSubmit={this.updateAccount}>
        <div className="row">
          <div className="large-12 columns">
            <label>Plan
              <select value={this.state.tempPlan} onChange={this.changePlan} name='plan'>
                {planOptions}
              </select>
            </label>
          </div>
        </div>
        <div className="row">
          <div className="large-12 columns">
            <button type='submit'>Save</button>
          </div>
        </div>
      </form>
    );
  }
});
