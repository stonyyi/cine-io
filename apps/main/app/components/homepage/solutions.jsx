/** @jsx React.DOM */
var React = require('react'),
PageWrapper = Cine.component('layout/_page_wrapper');

module.exports = React.createClass({
  displayName: 'HomepageSolutions',
  mixins: [Cine.lib('requires_app')],

  render: function() {

    return (
      <PageWrapper selected='solutions' app={this.props.app}>
        <h1>I am solutions</h1>
        <a href="https://www.siriusdecisions.com/Blog/2012/Aug/Whats-Really-the-Difference-Between-Solution-and-Product-Content.aspx">What’s Really the Difference Between Solution and Product Content?</a>
        <h2>Solutions</h2>
        <ul>
          <li> CDN </li>
          <li> Transcoding </li>
          <li> Recording </li>
          <li> HLS </li>
        </ul>
      </PageWrapper>
    );
  }
});
