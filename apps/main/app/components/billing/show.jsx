/** @jsx React.DOM */
var React = require('react'),
PageWrapper = Cine.component('layout/_page_wrapper'),
NewCreditCard = Cine.component('billing/_new_credit_card');
CurrentCreditCard = Cine.component('billing/_current_credit_card');

module.exports = React.createClass({
  displayName: 'BillingShow',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin'), Cine.lib('has_nav')],
  getBackboneObjects: function(){
    return this.props.app.currentUser;
  },
  render: function() {
    var CardModule = this.props.app.currentUser.get('stripeCard') ? CurrentCreditCard : NewCreditCard;

    return (
      <PageWrapper app={this.props.app}>
        <h1 className="bottom-margin-1">Billing Information</h1>
        <CardModule app={this.props.app} />
      </PageWrapper>
    );
  }
});
