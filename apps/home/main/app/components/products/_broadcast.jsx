/** @jsx React.DOM */
var React = require('react'),
  PageWrapper = Cine.component('layout/_page_wrapper'),
  BroadcastHero = Cine.component('products/broadcast/_broadcast_hero'),
  About = Cine.component('products/broadcast/_about'),
  Example = Cine.component('products/broadcast/_example'),
  Libraries = Cine.component('products/broadcast/_libraries'),
  Marketplaces = Cine.component('products/broadcast/_marketplaces');
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
        <BroadcastHero app={this.props.app} />
        <About />
        <Libraries />
        <Example app={this.props.app}/>
        <Marketplaces />
        <Consulting />
      </PageWrapper>
    );
  }
});
