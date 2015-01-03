/** @jsx React.DOM */
var React = require('react'),
  PageWrapper = Cine.component('layout/_page_wrapper'),
  HomeHero = Cine.component('homepage/_home_hero'),
  Products = Cine.component('homepage/_products'),
  Consulting = Cine.component('shared/_consulting');

module.exports = React.createClass({
  displayName: 'HomepageShow',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin'), Cine.lib('redirect_to_dashboard_on_login')],
  getBackboneObjects: function(){
    return this.props.app.currentUser;
  },
  render: function() {
      return (
        <PageWrapper app={this.props.app} wide={true} fixedNav={true} fadeLogo={true} className="homepage-logged-out">
          <HomeHero />
          <Products />
          <Consulting />
        </PageWrapper>
      );
  }
});
