/** @jsx React.DOM */
var React = require('react'),
  PageWrapper = Cine.component('layout/_page_wrapper'),
  SubmitButton = Cine.component('shared/_submit_button'),
  Account = Cine.model('account'),
  UsageReport = Cine.model('usage_report'),
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
    return {plan: currentAccount.firstPlan(), initialPlan: currentAccount.firstPlan(), submitting: false};
  },
  changePlan: function(event) {
    this.setState({plan: event.target.value});
  },
  updateSuccess: function(){
    if (this.state.plan != this.state.initialPlan){
      this.props.app.tracker.planChange(this.state.plan);
      this.setState({initialPlan: this.state.plan, submitting: false});
    } else {
      this.setState({submitting: false});
    }
  },
  updateAccount: function(e){
    e.preventDefault();
    var self = this;
      ca = self.props.app.currentAccount();
    if(this.state.submitting){
      return;
    }
    self.setState({submitting: true});
    ca.set({productPlans: {broadcast: [this.state.plan]}})
    ca.save(null,{
      success: function(model, response, options){
        self.updateSuccess()
        model.store();
        self.props.app.flash('Successfully updated plan.', 'success');
      },
      error: function(model, response, options){
        self.setState({submitting: false})
      }
    });
  },
  render: function() {
    var planOptions = _.map(UsageReport.sortedCinePlans('broadcast'), function(plan) {
      return (<option key={plan.name} value={plan.name}>{capitalize(plan.name)}</option>);
    });

    return (
      <form onSubmit={this.updateAccount}>
        <div className="row">
          <div className="large-12 columns">
            <label>Plan
              <select value={this.state.plan} onChange={this.changePlan} name='plan'>
                {planOptions}
              </select>
            </label>
          </div>
        </div>
        <div className="row">
          <div className="large-12 columns">
            <SubmitButton text="Save" submittingText="Saving Account" submitting={this.state.submitting}/>
          </div>
        </div>
      </form>
    );
  }
});
