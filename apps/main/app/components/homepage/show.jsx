/** @jsx React.DOM */
var React = require('react'),
Footer = Cine.component('layout/footer'),
Header = Cine.component('layout/header'),
LeftNav = Cine.component('layout/left_nav'),
LoggedOut = Cine.component('homepage/_logged_out'),
LoggedIn = Cine.component('homepage/_logged_in'),
HomeHero = LoggedOut.HomeHero,
About = LoggedOut.About,
Example = LoggedOut.Example,
Pricing = LoggedOut.Pricing,
Projects = Cine.collection('projects'),
cx = Cine.lib('cx');

module.exports = React.createClass({
  displayName: 'HomepageShow',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin')],

  getInitialState: function(){
    return{
      showingLeftNav: false,
      projects: new Projects([], {app: this.props.app})
    };
  },
  getBackboneObjects: function(){
    return this.props.app.currentUser;
  },
  toggleLeftNav: function(e){
    e.preventDefault();
    this.setState({showingLeftNav: !this.state.showingLeftNav});
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
      var canvasClasses = cx({
        'off-canvas-wrap': true,
        'move-right': this.state.showingLeftNav
      });

      return (
        <div id='homepage-logged-out' className={canvasClasses}>
          <div className="inner-wrap">
            { /*<a onClick={this.toggleLeftNav} href="" >Menu JS</a> */ }

            <LeftNav app={this.props.app} showing={this.state.showingLeftNav}/>
            <HomeHero />
            <About />
            <Example />
            <Pricing />
            <Footer />
          </div>
        </div>
      );
    }

  }
});
