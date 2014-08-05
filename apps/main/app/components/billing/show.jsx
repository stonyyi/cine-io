/** @jsx React.DOM */
var React = require('react'),
Header = Cine.component('layout/header'),
Footer = Cine.component('layout/footer'),
LeftNav = Cine.component('layout/left_nav'),
FlashHolder = Cine.component('layout/flash_holder'),
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
      <div id='docs' className={this.canvasClasses()}>
        <FlashHolder app={this.props.app}/>
        <div className="inner-wrap">
          <LeftNav app={this.props.app} showing={this.state.showingLeftNav}/>
          <Header app={this.props.app} />
          <div className="container">
            <h1 className="bottom-margin-1">Billing Information</h1>
            {content}
          </div>
        </div>
        <Footer />
      </div>
    );
  }
});
