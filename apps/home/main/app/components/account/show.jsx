/** @jsx React.DOM */
var React = require('react'),
PageWrapper = Cine.component('layout/_page_wrapper'),
NewCreditCard = Cine.component('account/_new_credit_card'),
ChangePlanForm = Cine.component('account/_change_plan_form'),
CurrentCreditCard = Cine.component('account/_current_credit_card'),
NoAccount = Cine.component('shared/_no_account'),
DeleteAccount = Cine.component('account/_delete_account');

module.exports = React.createClass({
  displayName: 'AccountShow',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin')],
  getBackboneObjects: function(){
    return this.props.app.currentAccount();
  },
  render: function() {
    var
      ca = this.props.app.currentAccount();
    if (ca == null){
      return (<NoAccount app={this.props.app}/>);
    }
    var
      CardModule = ca.get('stripeCard') ? CurrentCreditCard : NewCreditCard,
      accountActions;
    if (ca.isHeroku()){
      accountActions = (
        <div>
          <span>Current plan: {ca.firstPlan()}. {" "}</span>
          <a target="_blank" href="https://addons.heroku.com/cine">Change plan on Heroku</a>
        </div>
      );
    }else if (ca.isAppdirect()){
      var appdirectUrl = ca.get('appdirect').baseUrl+"/account/apps/";
      accountActions = (
        <div>
          <span>Current plan: {ca.firstPlan()}. {" "}</span>
          <a target="_blank" href={appdirectUrl}>Change plan on Appdirect</a>
        </div>
      );
    }else{
      accountActions = (
        <div>
          <ChangePlanForm app={this.props.app} />
          <CardModule app={this.props.app} />
          <hr/>
          <DeleteAccount app={this.props.app} model={ca} />
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

        {accountActions}
      </PageWrapper>
    );
  }
});
