/** @jsx React.DOM */
var React = require('react'),
  PageWrapper = Cine.component('layout/_page_wrapper'),
  PeerHero = Cine.component('products/peer/_peer_hero'),
  About = Cine.component('products/peer/_about'),
  Example = Cine.component('products/peer/_example'),
  Consulting = Cine.component('shared/_consulting');

module.exports = React.createClass({
  displayName: 'ProductsBroadcast',
  mixins: [Cine.lib('requires_app')],

  getInitialState: function(){
    return {};
  },
  render: function() {
    return (
      <PageWrapper app={this.props.app} wide={true}>
        <PeerHero app={this.props.app} />
        <About />
        <Example app={this.props.app}/>
        <Consulting />
      </PageWrapper>
    );
  }
});
