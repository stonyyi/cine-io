/** @jsx React.DOM */
var
  React = require('react'),
  PageWrapper = Cine.component('layout/_page_wrapper'),
  BandwidthGraph = Cine.component('usage_reports/_bandwidth_graph');
  PeerMinutesGraph = Cine.component('usage_reports/_peer_minutes_graph');
  Storage = Cine.component('usage_reports/_storage');

module.exports = React.createClass({
  displayName: 'UsageReportsShow',
  mixins: [Cine.lib('requires_app')],
  render: function() {
    return (
      <PageWrapper app={this.props.app}>
        <div className='row'>
          <div className='small-12 columns'>
            <h1>Usage Report</h1>
            <h3>Broadcast</h3>
            <BandwidthGraph model={this.props.model} app={this.props.app}/>
            <hr/>
            <Storage model={this.props.model} app={this.props.app}/>
            <h3>Peer</h3>
            <PeerMinutesGraph model={this.props.model} app={this.props.app}/>
          </div>
        </div>
      </PageWrapper>
    );
  }
});
