/** @jsx React.DOM */
var React = require('react'),
Footer = Cine.component('layout/footer'),
Header = Cine.component('layout/header'),
LoggedOut = Cine.component('homepage/_logged_out'),
LoggedIn = Cine.component('homepage/_logged_in'),
HomeHero = LoggedOut.HomeHero,
About = LoggedOut.About,
Pricing = LoggedOut.Pricing;

module.exports = React.createClass({
  componentWillMount: function() {
    this.props.app.currentUser.on("change", (function() {
      this.forceUpdate();
    }.bind(this)));
  },

  render: function() {
    if (this.props.app.currentUser.isLoggedIn()) {
      return (
        <div id='homepage'>
          <Header app={this.props.app}/>
          <LoggedIn />
          <Footer />
        </div>
      );

    }else{
      return (
        <div id='homepage'>
          <HomeHero />
          <About />
          <Pricing />
          <Footer />
        </div>
      );
    }

  }
});
