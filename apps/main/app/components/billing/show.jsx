/** @jsx React.DOM */
var React = require('react'),
PageWrapper = Cine.component('layout/_page_wrapper'),
NewCreditCard = Cine.component('billing/_new_credit_card');

module.exports = React.createClass({
  displayName: 'BillingShow',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin'), Cine.lib('has_nav')],
  getBackboneObjects: function(){
    return this.props.app.currentUser;
  },
  render: function() {
    var cu = this.props.app.currentUser,
      card = cu.get('stripeCard'),
      content;
    if (card){
      content = (
        <div>
          Card on file: {card.brand}, {card.last4}, {card.exp_month} / {card.exp_year}
        </div>
      )
    }else{
      content = (<NewCreditCard app={this.props.app}/>)
    }
    return (
      <PageWrapper app={this.props.app}>
        <h1 className="bottom-margin-1">Billing Information</h1>
        {content}
      </PageWrapper>
    );
  }
});
