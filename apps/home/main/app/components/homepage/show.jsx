/** @jsx React.DOM */
var React = require('react'),
PageWrapper = Cine.component('layout/_page_wrapper');

module.exports = React.createClass({
  displayName: 'HomepageShow',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin')],
  getBackboneObjects: function(){
    return this.props.app.currentUser;
  },
  redirectToDashboard: function(){
    this.props.app.router.redirectTo('/dashboard');
  },
  componentDidMount: function() {
    this.props.app.currentUser.on('login', this.redirectToDashboard);
  },
  componentWillUnmount: function() {
    this.props.app.currentUser.off('login', this.redirectToDashboard);
  },

  render: function() {
      return (
        <PageWrapper app={this.props.app} wide={true} fixedNav={true} fadeLogo={true} className="homepage-logged-out">
        The homepage
        </PageWrapper>
      );
  }
});
