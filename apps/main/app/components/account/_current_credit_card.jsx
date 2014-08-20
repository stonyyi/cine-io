/** @jsx React.DOM */
var React = require('react');

module.exports = React.createClass({
  displayName: 'CurrentCreditCard',
  mixins: [Cine.lib('requires_app')],
  deleteCard: function(event){
    var app = this.props.app;
    event.preventDefault();
    app.currentAccount().set('deleteCard', this.props.app.currentAccount().get('stripeCard').id);
    app.currentAccount().save(null, {
      success: function(model, response, options){
        model.unset('deleteCard');
        // sending {stripeCard: undefined} from the server
        // does not return a stripeCard attribute
        // therefore we need to manually remove it.
        // we check for it's presence,
        // and then manually remove it
        if (!response.stripeCard){
          model.unset('stripeCard');
        }
        model.store();
        app.flash('Successfully removed credit card.', 'success');
      },
      error: function(model, response, options){
        model.unset('deleteCard');
        app.flash('Could not remove credit card.', 'alert');
      }
    });
  },
  render: function() {
    var cu = this.props.app.currentAccount(),
      card = cu.get('stripeCard');
    return (
      <div>
        Card on file: {card.brand}, {card.last4}, {card.exp_month} / {card.exp_year}
        <a href="" onClick={this.deleteCard}><span className="fa fa-times" /></a>
      </div>
    );
  }
});
