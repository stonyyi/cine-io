/** @jsx React.DOM */
var React = require('react'),
  PageWrapper = Cine.component('layout/_page_wrapper'),
  About = Cine.component('products/peer/_about'),
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
        <About />
        <Consulting />
      </PageWrapper>
    );
  }
});
