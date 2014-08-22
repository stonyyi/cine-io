/** @jsx React.DOM */
var React = require('react'),
PageWrapper = Cine.component('layout/_page_wrapper'),
NewCreditCard = Cine.component('account/_new_credit_card'),
ChangePlanForm = Cine.component('account/_change_plan_form'),
CurrentCreditCard = Cine.component('account/_current_credit_card');

module.exports = React.createClass({
  displayName: 'AccountShow',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin')],
  getBackboneObjects: function(){
    return this.props.app.currentAccount();
  },
  render: function() {
    var
      ca = this.props.app.currentAccount(),
      CardModule = ca.get('stripeCard') ? CurrentCreditCard : NewCreditCard,
      changePlan;
    if (ca.get('herokuId')){
      changePlan = (
        <div>
          <span>Current plan: {ca.firstPlan()}. {" "}</span>
          <a href="https://addons.heroku.com/cine">Change plan on Heroku</a>
        </div>
      );
    }else{
      changePlan = (
        <div>
          <ChangePlanForm app={this.props.app} />
          <CardModule app={this.props.app} />
        </div>
      );
    }
    return (
      <PageWrapper app={this.props.app}>
        <h1 className="bottom-margin-1">Account Information</h1>
        <div className="row">
          <dl className="columns large-12">
            <dt>Master Key</dt>
            <dd>{this.props.app.currentAccount().get('masterKey')}</dd>
          </dl>
        </div>

        {changePlan}
      </PageWrapper>
    );
  }
});
