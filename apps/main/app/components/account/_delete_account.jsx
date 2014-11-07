/** @jsx React.DOM */
var React = require('react'),
  DeleteButtonWithInputConfirmation = Cine.component('shared/_delete_button_with_input_confirmation'),
  Account = Cine.model('account'),
  _ = require('underscore'),
  capitalize = Cine.lib('capitalize');

module.exports = React.createClass({
  displayName: 'DeleteAccount',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin')],
  propTypes: {
    model: React.PropTypes.instanceOf(Account).isRequired
  },
  getBackboneObjects: function(){
    return this.props.app.currentAccount();
  },
  getInitialState: function(){
    return {isDeleting: false};
  },
  destroyAccount: function(e){
    var
      self = this,
      app = self.props.app;
    if(this.state.isDeleting){
      return;
    }
    self.setState({isDeleting: true});
    this.props.model.destroy({
      data: {
        masterKey: this.props.model.get('masterKey')
      },
      processData: true,
      wait: true,
      success: function(model, response){
        if (self.isMounted()){
          self.setState({isDeleting: false});
        }
        app.flash('Successfully deleted account.', 'success');
        var newAccount = app.currentUser.accounts().first();
        app.changeAccount(newAccount);
      },
      error: function(model, response){
        app.flash('Could not delete account.', 'warning');
        if (self.isMounted()){
          self.setState({isDeleting: false});
        }
      }
    });
  },
  render: function() {
    var
      model = this.props.model,
      confirmationAttribute = model.get('name') ? 'name' : 'email';
    return (
      <div>
        <h3>Delete Account</h3>
        <DeleteButtonWithInputConfirmation model={model} isDeleting={this.state.isDeleting} confirmationAttribute={confirmationAttribute} deleteCallback={this.destroyAccount} objectName="account" />
      </div>
    );
  }
});
