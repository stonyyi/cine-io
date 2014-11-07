/** @jsx React.DOM */
var React = require('react');


module.exports = React.createClass({
  displayName: 'CurrentCreditCard',
  mixins: [Cine.lib('requires_app')],
  getInitialState: function(){
    return {isDeleting: false};
  },
  doNothing: function(e){
    e.preventDefault();
  },
  deleteCard: function(event){
    event.preventDefault();
    if(this.state.isDeleting){return;}
    this.setState({isDeleting: true});
    var
      self = this,
      app = this.props.app;
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
        if (self.isMounted()){
          self.setState({isDeleting: false});
        }
      },
      error: function(model, response, options){
        model.unset('deleteCard');
        app.flash('Could not remove credit card.', 'alert');
        if (self.isMounted()){
          self.setState({isDeleting: false});
        }
      }
    });
  },
  render: function() {
    var cu = this.props.app.currentAccount(),
      card = cu.get('stripeCard'),
      cardAction;
    if(this.state.isDeleting){
      cardAction = (<a href="" className="disabled" disabled onClick={this.doNothing}><span className="fa fa-times" /></a>);
    }else{
      cardAction = (<a href="" onClick={this.deleteCard}><span className="fa fa-times" /></a>);
    }
    return (
      <div>
        Card on file: {card.brand}, {card.last4}, {card.exp_month} / {card.exp_year}
        {cardAction}
      </div>
    );
  }
});
