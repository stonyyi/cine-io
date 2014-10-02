/** @jsx React.DOM */
var
  React = require('react'),
  PageWrapper = Cine.component('layout/_page_wrapper'),
  BandwidthGraph = Cine.component('usage_reports/_bandwidth_graph');
  Storage = Cine.component('usage_reports/_storage');

module.exports = React.createClass({
  displayName: 'UsageReportsShow',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin')],
  getBackboneObjects: function(){
    return this.props.model;
  },
  render: function() {
    return (
      <PageWrapper app={this.props.app}>
        <div className='row'>
          <div className='small-12 columns'>
            <h1>Usage Report</h1>
            <BandwidthGraph model={this.props.model} app={this.props.app}/>
            <Storage model={this.props.model} app={this.props.app}/>
          </div>
        </div>
      </PageWrapper>
    );
  }
});
