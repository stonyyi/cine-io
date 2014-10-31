/** @jsx React.DOM */
var React = require('react'),
  SubmitButton = Cine.component('shared/_submit_button');

module.exports = React.createClass({
  displayName: 'NewCreditCard',
  mixins: [Cine.lib('requires_app')],
  getInitialState: function(){
    return {creditCard: null, expiration: null, cvc: null, submitting: false};
  },
  changeCreditCard: function(event){
    this.setState({creditCard: event.target.value});
  },
  changeExipration: function(event){
    console.log('setting expiration', event.target.value)
    this.setState({expiration: event.target.value});
  },
  changeCvc: function(event){
    this.setState({cvc: event.target.value});
  },
  componentDidMount: function(){
    this.refs.creditField.getDOMNode().focus()
  },
  componentDidUpdate: function(){
    $(this.refs.creditField.getDOMNode()).payment('formatCardNumber');
    $(this.refs.expField.getDOMNode()).payment('formatCardExpiry');
    $(this.refs.cvcField.getDOMNode()).payment('formatCardCVC');
  },
  validateAndSaveCreditCard: function(event){
    event.preventDefault();
    var expiration = $.payment.cardExpiryVal(this.state.expiration);
    var stripeData = {
      number: this.state.creditCard,
      cvc: this.state.cvc,
      exp_month: expiration.month,
      exp_year: expiration.year
    }
    if (!this.validateNewCreditCard(stripeData)){
      return;
    }
    this.setState({submitting: true});
    Stripe.card.createToken(stripeData, this.saveCreditCard)
  },
  saveCreditCard: function(status, response){
    if(response.error){
      this.setState({submitting: false});
      this.props.app.flash(response.error.message, 'alert');
      return;
    }
    var
      self = this,
      stripeToken = response.id,
      app = this.props.app;
    app.currentAccount().set('stripeToken', response.id)
    app.currentAccount().save(null, {
      success: function(model, response, options){
        self.setState({submitting: false});
        model.unset('stripeToken');
        model.store();
        app.flash('Successfully saved credit card.', 'success');
        app.tracker.addedCard();
      },
      error: function(model, response, options){
        self.setState({submitting: false});
        model.unset('stripeToken');
        app.flash('Could not save credit card.', 'alert');
      }
    });
  },
  validateNewCreditCard: function(stripeData){
    if (!Stripe.card.validateCardNumber(stripeData.number)) {
      this.props.app.flash('Invalid card number.', 'alert');
      return false;
    }
    if (!Stripe.card.validateExpiry(stripeData.exp_month, stripeData.exp_year)) {
      this.props.app.flash('Invalid expiration date.', 'alert');
      return false;
    }
    if (!Stripe.card.validateCVC(stripeData.cvc)) {
      this.props.app.flash('Invalid cvc.', 'alert');
      return false;
    }
    return true;
  },
  render: function() {
    return (
      <div>
        <form onSubmit={this.validateAndSaveCreditCard}>
          <div className="row">
            <div className="large-offset-3 large-6 columns ">
              <label>
                <div className="clearfix">
                  <span className="left">Card number</span>
                  <span className='right'>
                    <small><i className="fa fa-lock"></i></small>
                    <small>Secure</small>
                  </span>
                </div>
                <input type='tel' ref="creditField" className="credit-card-field" name="stripe[credit_card]" required value={this.state.creditCard} onChange={this.changeCreditCard} placeholder="•••• •••• •••• ••••"/>
              </label>
            </div>
          </div>
          <div className="row">
            <div className="large-offset-3 large-3 columns">
              <label>
                Expiration
                <input type='tel' ref="expField" name="stripe[expiration]" required value={this.state.expiration} onChange={this.changeExipration} placeholder="MM / YY"/>
              </label>
            </div>
            <div className="large-3 columns end">
              <label>
                Security code
                <input type='tel' ref="cvcField" name="stripe[cvc]" required value={this.state.cvc} onChange={this.changeCvc} placeholder="CVC" maxLength="4" pattern="\d*"/>
              </label>
            </div>
          </div>
          <div className="row">
            <div className="large-offset-3 columns">
              <SubmitButton className='radius' text="Save credit card" submittingText="Saving credit card" submitting={this.state.submitting}/>
            </div>
          </div>
        </form>
      </div>
    );
  }
});
