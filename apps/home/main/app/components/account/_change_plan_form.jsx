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
    return {
      broadcastPlan: currentAccount.broadcastPlans()[0],
      initialBroadcastPlan: currentAccount.broadcastPlans()[0],
      peerPlan: currentAccount.peerPlans()[0],
      initialPeerPlan: currentAccount.peerPlans()[0],
      submitting: false
    };
  },
  changeBroadcastPlan: function(event) {
    this.setState({broadcastPlan: event.target.value});
  },
  changePeerPlan: function(event) {
    this.setState({peerPlan: event.target.value});
  },
  updateSuccess: function(){
    var newState = {submitting: false}
    if (this.state.broadcastPlan != this.state.initialBroadcastPlan){
      this.props.app.tracker.planChange(this.state.broadcastPlan);
      newState.initialBroadcastPlan = this.state.broadcastPlan;
    }
    if (this.state.peerPlan != this.state.initialPeerPlan){
      this.props.app.tracker.planChange(this.state.peerPlan);
      newState.initialPeerPlan = this.state.peerPlan;
    }
    this.setState(newState);
  },
  updateAccount: function(e){
    e.preventDefault();
    var self = this;
      ca = self.props.app.currentAccount();
    if(this.state.submitting){
      return;
    }
    self.setState({submitting: true});
    ca.set({productPlans: {broadcast: [this.state.broadcastPlan], peer: [this.state.peerPlan]}})
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
  _planOptions: function(product){
   return _.map(UsageReport.sortedCinePlans(product), function(plan) {
      var key = product + plan.name;
      return (<option key={key} value={plan.name}>{capitalize(plan.name)}</option>);
    });
  },
  render: function() {
    var
      broadcastPlanOptions = this._planOptions('broadcast'),
      peerPlanOptions = this._planOptions('peer');

    return (
      <form onSubmit={this.updateAccount}>
        <div className="row">
          <div className="large-6 columns">
            <label><i className="cine-broadcast"></i>&nbsp;Broadcast Plan
              <select value={this.state.broadcastPlan} onChange={this.changeBroadcastPlan} name='broadcast'>
                {broadcastPlanOptions}
              </select>
            </label>
          </div>
          <div className="large-6 columns">
            <label><i className="cine-conference"></i>&nbsp;Peer Plan
              <select value={this.state.peerPlan} onChange={this.changePeerPlan} name='peer'>
                {peerPlanOptions}
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
