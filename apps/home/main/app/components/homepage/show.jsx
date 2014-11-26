/** @jsx React.DOM */
var React = require('react'),
PageWrapper = Cine.component('layout/_page_wrapper'),
LoggedOut = Cine.component('homepage/_logged_out'),
HomeHero = Cine.component('homepage/_home_hero'),
About = LoggedOut.About,
Example = LoggedOut.Example,
Libraries = Cine.component('homepage/_libraries'),
Consulting = LoggedOut.Consulting,
Marketplaces = LoggedOut.Marketplaces,
NoAccount = Cine.component('shared/_no_account'),
Projects = Cine.collection('projects');

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
          <HomeHero app={this.props.app} />
          <About />
          <Libraries />
          <Example app={this.props.app}/>
          <Marketplaces />
          <Consulting />
        </PageWrapper>
      );
  }
});
