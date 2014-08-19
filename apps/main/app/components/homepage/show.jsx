/** @jsx React.DOM */
var React = require('react'),
PageWrapper = Cine.component('layout/_page_wrapper'),
FlashHolder = Cine.component('layout/flash_holder'),
Header = Cine.component('layout/header'),
LeftNav = Cine.component('layout/left_nav'),
Footer = Cine.component('layout/footer'),
LoggedOut = Cine.component('homepage/_logged_out'),
LoggedIn = Cine.component('homepage/_logged_in'),
HomeHero = LoggedOut.HomeHero,
About = LoggedOut.About,
Example = LoggedOut.Example,
Libraries = LoggedOut.Libraries,
Pricing = LoggedOut.Pricing,
Consulting = LoggedOut.Consulting,
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
        <PageWrapper app={this.props.app}>
          <LoggedIn app={this.props.app} collection={this.state.projects} masterKey={this.props.app.currentAccount().get('masterKey')}/>
        </PageWrapper>
      );

    }else{
      return (
        <div id='homepage-logged-out' className={this.canvasClasses()}>
          <FlashHolder app={this.props.app}/>
          <div className="inner-wrap">
            <LeftNav app={this.props.app} showing={this.state.showingLeftNav}/>
            <HomeHero app={this.props.app} />
            <About />
            <Libraries />
            <Example app={this.props.app}/>
            <Pricing app={this.props.app} />
            <Consulting />
            <Footer />
          </div>
        </div>
      );
    }

  }
});
