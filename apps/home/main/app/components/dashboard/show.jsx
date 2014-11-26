/** @jsx React.DOM */
var React = require('react'),
PageWrapper = Cine.component('layout/_page_wrapper'),
LoggedIn = Cine.component('dashboard/_content'),
NoAccount = Cine.component('shared/_no_account');

module.exports = React.createClass({
  displayName: 'DashboardShow',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin')],

  getBackboneObjects: function(){
    return this.props.app.currentUser;
  },
  render: function() {

    var currentAccount = this.props.app.currentAccount();
    if (currentAccount == null){
      return (<NoAccount app={this.props.app} />);
    }
    return (
      <PageWrapper app={this.props.app}>
        <LoggedIn app={this.props.app} masterKey={currentAccount.get('masterKey')}/>
      </PageWrapper>
    );
  }
});
