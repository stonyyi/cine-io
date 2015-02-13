/** @jsx React.DOM */
var React = require('react'),
  PageWrapper = Cine.component('layout/_page_wrapper'),
  Hero = Cine.component('products/webrtc_broadcast/_hero'),
  About = Cine.component('products/webrtc_broadcast/_about'),
  Example = Cine.component('products/webrtc_broadcast/_example'),
  Libraries = Cine.component('products/webrtc_broadcast/_libraries'),
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
        <Hero app={this.props.app} />
        <About />
        <Libraries />
        <Example app={this.props.app}/>
        <Consulting />
      </PageWrapper>
    );
  }
});
