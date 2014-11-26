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
  drawPieChart: function(usedStorageInBytes, planStorageInBytes){
    var
      availableStorageInBytes = planStorageInBytes - usedStorageInBytes,
      data = google.visualization.arrayToDataTable([
        ['Storage', 'Used'],
        ["Used (" + humanizeBytes(usedStorageInBytes)+")",     usedStorageInBytes],
        ["Free ("+ humanizeBytes(availableStorageInBytes)+")", availableStorageInBytes]
      ]);

    var options = {
      title: 'Cloud Storage',
      enableInteractivity: false,
      sliceVisibilityThreshold: 0
    };

    var chart = new google.visualization.PieChart(this.refs['chartDiv'].getDOMNode());
    chart.draw(data, options);
  },
  drawBarChart: function(usedStorageInBytes, planStorageInBytes){
    var
      formatString = humanizeBytes.formatString(planStorageInBytes),
      data = [["Total Storage", { role: 'annotation' }, "Usage"]],
      storageAvailableInFormat = planStorageInBytes / humanizeBytes[formatString]
      storageUsageInFormat = usedStorageInBytes / humanizeBytes[formatString]
      dataOptions = ["", humanizeBytes(usedStorageInBytes), storageUsageInFormat];
      data.push(dataOptions)
      // data.push();

    var options = {
      vAxis: {title: "Storage ("+formatString+")", minValue: 0},
      hAxis: {title: "Used Storage"},
      seriesType: "bars",
      enableInteractivity: false,
      legend: {position: 'none'}
    };

    var chart = new google.visualization.ComboChart(this.refs['chartDiv'].getDOMNode());
    chart.draw(google.visualization.arrayToDataTable(data), options);
  },
  loadChart: function(){
    var
      usedStorageInBytes = this.props.model.get('storage');
      planStorageInBytes = UsageReport.maxUsagePerAccount(this.props.app.currentAccount(), 'storage');
    if (usedStorageInBytes <= planStorageInBytes) {
      this.drawPieChart(usedStorageInBytes, planStorageInBytes);
    }else{
      this.drawBarChart(usedStorageInBytes, planStorageInBytes);
    }
  },
  render: function(){
    return (<div ref="chartDiv" />);
  }
});
