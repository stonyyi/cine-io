/** @jsx React.DOM */
var React = require('react'),
PageWrapper = Cine.component('layout/_page_wrapper'),
LoggedOut = Cine.component('homepage/_logged_out'),
LoggedIn = Cine.component('homepage/_logged_in'),
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
  render: function() {

    if (this.props.app.currentUser.isLoggedIn()) {
      var currentAccount = this.props.app.currentAccount();
      if (currentAccount == null){
        return (<NoAccount app={this.props.app} />);
      }
      return (
        <PageWrapper app={this.props.app}>
          <LoggedIn app={this.props.app} masterKey={currentAccount.get('masterKey')}/>
        </PageWrapper>
      );

    }else{
      return (
        <PageWrapper app={this.props.app} wide={true} fixedNav={true} className="homepage-logged-out">
          <div className="row top-margin-2">
          <HomeHero app={this.props.app} />
          </div>
          <About />
          <Libraries />
          <Example app={this.props.app}/>
          <Marketplaces />
          <Consulting />
        </PageWrapper>
      );
    }

  }
});
