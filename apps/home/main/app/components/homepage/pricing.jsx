/** @jsx React.DOM */
var React = require('react'),
Pricing = Cine.component('homepage/_pricing'),
PageWrapper = Cine.component('layout/_page_wrapper');

module.exports = React.createClass({
  displayName: 'HomepagePricing',
  mixins: [Cine.lib('requires_app')],
  componentDidMount: function() {
    this.props.app.currentUser.on('login', this.redirectToDashboard);
  },
  componentWillUnmount: function() {
    this.props.app.currentUser.off('login', this.redirectToDashboard);
  },
  redirectToDashboard: function(){
    this.props.app.router.redirectTo('/dashboard');
  },
  render: function() {

    return (
      <PageWrapper selected='pricing' fixedNav={true} app={this.props.app} wide={true}>
        <Pricing app={this.props.app} />
      </PageWrapper>
    );
  }
});
