/** @jsx React.DOM */
var React = require('react'),
Header = Cine.component('layout/header'),
LeftNav = Cine.component('layout/left_nav'),
LoggedOut = Cine.component('homepage/_logged_out'),
LoggedIn = Cine.component('homepage/_logged_in'),
FlashHolder = Cine.component('layout/flash_holder'),
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
  componentDidMount: function(){
    this.props.app.currentUser.on('login', this.closeNav, this);
    this.props.app.currentUser.on('logout', this.closeNav, this);
  },
  componentWillUnMount: function(){
    this.props.app.currentUser.off('login', this.closeNav);
    this.props.app.currentUser.off('logout', this.closeNav);
  },
  closeNav: function(){
    this.setState({showingLeftNav: false});
  },
  openNav: function(){
    this.setState({showingLeftNav: true});
  },
  getBackboneObjects: function(){
    return this.props.app.currentUser;
  },
  toggleLeftNav: function(e){
    e.preventDefault();
    this.setState({showingLeftNav: !this.state.showingLeftNav});
  },
  render: function() {
    var canvasClasses = cx({
      'off-canvas-wrap': true,
      'move-right': this.state.showingLeftNav
    });

    if (this.props.app.currentUser.isLoggedIn()) {
      return (
        <div id='homepage-logged-in' className={canvasClasses}>
          <FlashHolder app={this.props.app}/>
          <div className="inner-wrap">
            <LeftNav app={this.props.app} showing={this.state.showingLeftNav}/>
            <Header app={this.props.app} />
            <LoggedIn app={this.props.app} collection={this.state.projects} />
          </div>
        </div>
      );

    }else{
      return (
        <div id='homepage-logged-out' className={canvasClasses}>
          <FlashHolder app={this.props.app}/>
          <div className="inner-wrap">
            { /*<a onClick={this.toggleLeftNav} href="" >Menu JS</a> */ }

            <LeftNav app={this.props.app} showing={this.state.showingLeftNav}/>
            <HomeHero />
            <About />
            <Example />
            <Pricing />
          </div>
        </div>
      );
    }

  }
});
