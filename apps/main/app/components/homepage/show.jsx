/** @jsx React.DOM */
var React = require('react'),
Footer = Cine.component('layout/footer'),
Header = Cine.component('layout/header'),
LoggedOut = Cine.component('homepage/_logged_out'),
LoggedIn = Cine.component('homepage/_logged_in'),
HomeHero = LoggedOut.HomeHero,
About = LoggedOut.About,
Example = LoggedOut.Example,
Pricing = LoggedOut.Pricing,
Projects = Cine.collection('projects');

module.exports = React.createClass({
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin')],

  getInitialState: function(){
    return{
      projects: new Projects([], {app: this.props.app})
    };
  },
  getBackboneObjects: function(){
    return this.props.app.currentUser;
  },
  render: function() {
    if (this.props.app.currentUser.isLoggedIn()) {
      return (
        <div id='homepage-logged-in'>
          <Header app={this.props.app} />
          <LoggedIn app={this.props.app} collection={this.state.projects} />
          <Footer />
        </div>
      );

    }else{
      return (
        <div id='homepage-logged-out'>
          <HomeHero />
          <About />
          <Example />
          <Pricing />
          <Footer />
        </div>
      );
    }

  }
});
