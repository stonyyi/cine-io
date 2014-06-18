/** @jsx React.DOM */
var React = require('react'),
Header = Cine.component('layout/header'),
LeftNav = Cine.component('layout/left_nav'),
LoggedOut = Cine.component('homepage/_logged_out'),
LoggedIn = Cine.component('homepage/_logged_in'),
FlashHolder = Cine.component('layout/flash_holder'),
Footer = Cine.component('layout/footer'),
HomeHero = LoggedOut.HomeHero,
About = LoggedOut.About,
Example = LoggedOut.Example,
Libraries = LoggedOut.Libraries,
Pricing = LoggedOut.Pricing,
Projects = Cine.collection('projects');

module.exports = React.createClass({
  displayName: 'HomepageShow',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin'), Cine.lib('has_nav')],

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
        <div id='homepage-logged-in' className={this.canvasClasses()}>
          <FlashHolder app={this.props.app}/>
          <div className="inner-wrap">
            <LeftNav app={this.props.app} showing={this.state.showingLeftNav}/>
            <Header app={this.props.app} />
            <LoggedIn app={this.props.app} collection={this.state.projects} />
          </div>
          <Footer />
        </div>
      );

    }else{
      return (
        <div id='homepage-logged-out' className={this.canvasClasses()}>
          <FlashHolder app={this.props.app}/>
          <div className="inner-wrap">
            <LeftNav app={this.props.app} showing={this.state.showingLeftNav}/>
            <HomeHero app={this.props.app} />
            <About />
            <Example app={this.props.app}/>
            <Libraries />
            <Pricing app={this.props.app} />
            <Footer />
          </div>
        </div>
      );
    }

  }
});
