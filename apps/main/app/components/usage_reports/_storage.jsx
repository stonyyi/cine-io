/** @jsx React.DOM */
var
  React = require('react'),
  humanizeBytes = Cine.lib('humanize_bytes'),
  UsageReport = Cine.model('usage_report'),
  _ = require('underscore');

module.exports = React.createClass({
  displayName: "Storage",
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin')],
  getBackboneObjects: function(){
    return this.props.model;
  },
  componentDidMount: function(){
    if (document.readyState !== 'complete'){
      google.setOnLoadCallback(this.loadChart);
    }else{
      this.loadChart();
    }
  },
  loadChart: function(){
    var
      storageUsage = this.props.model.get('storage');
      planStorageInBytes = UsageReport.maxUsagePerAccount(this.props.app.currentAccount(), 'storage'),
      availableStorage = planStorageInBytes - storageUsage;

    var data = google.visualization.arrayToDataTable([
      ['Storage', 'Used'],
      ["Used (" + humanizeBytes(storageUsage)+")",     storageUsage],
      ["Free ("+ humanizeBytes(availableStorage)+")", availableStorage]
    ]);

    var options = {
      title: 'Cloud Storage',
      enableInteractivity: false,
      sliceVisibilityThreshold: 0
    };

    var chart = new google.visualization.PieChart(this.refs['chartDiv'].getDOMNode());
    chart.draw(data, options);
  },
  render: function(){
    return (<div ref="chartDiv" />);
  }
});
