/** @jsx React.DOM */
var React = require('react'),
Header = Cine.component('layout/header'),
Footer = Cine.component('layout/footer'),
LeftNav = Cine.component('layout/left_nav'),
FlashHolder = Cine.component('layout/flash_holder'),
NewCreditCard = Cine.component('billing/_new_credit_card');

module.exports = React.createClass({
  displayName: 'BillingShow',
  mixins: [Cine.lib('requires_app'), Cine.lib('has_nav')],
  render: function() {
    return (
      <div id='docs' className={this.canvasClasses()}>
        <FlashHolder app={this.props.app}/>
        <div className="inner-wrap">
          <LeftNav app={this.props.app} showing={this.state.showingLeftNav}/>
          <Header app={this.props.app} />
          <div className="container">
            <h1 className="bottom-margin-1">Billing Information</h1>
            <NewCreditCard app={this.props.app}/>
          </div>
        </div>
        <Footer />
      </div>
    );
  }
});
