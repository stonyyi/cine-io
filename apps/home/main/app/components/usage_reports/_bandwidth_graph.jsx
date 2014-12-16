/** @jsx React.DOM */
var
  React = require('react'),
  humanizeBytes = Cine.lib('humanize_bytes'),
  UsageReport = Cine.model('usage_report'),
  _ = require('underscore');

module.exports = React.createClass({
  displayName: "BandwidthGraph",
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
    var ltm = UsageReport.lastThreeMonths(),
      model = this.props.model,
      data = [["Month", { role: 'annotation' }, "Usage", "Cap"]],
      planBandwidthInBytes = UsageReport.maxUsagePerAccount(this.props.app.currentAccount(), 'bandwidth', 'broadcast'),
      formatString = humanizeBytes.formatString(planBandwidthInBytes),
      planUsage = planBandwidthInBytes / humanizeBytes[formatString];

    _.each(ltm, function(month){
      var bandwidth = model.get('bandwidth')
      var monthlyUsage = bandwidth[month.format] / humanizeBytes[formatString];
      var dateString = ('0' + (month.date.getMonth()+1)).slice(-2) + " / " + month.date.getFullYear();
      data.push([dateString, humanizeBytes(bandwidth[month.format]), monthlyUsage, planUsage]);
    });

    var options = {
      vAxis: {title: "Bandwidth ("+formatString+")"},
      hAxis: {title: "Month"},
      seriesType: "bars",
      legend: {position: 'none'},
      series: {1: {type: "line"}}
    };

    var chart = new google.visualization.ComboChart(this.refs['chartDiv'].getDOMNode());
    chart.draw(google.visualization.arrayToDataTable(data), options);
  },
  render: function(){
    return (<div ref="chartDiv" />);
  }
});
