/** @jsx React.DOM */
var
  React = require('react'),
  humanizeNumber = Cine.lib('humanize_number'),
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
      planMinutesInMilliseconds = UsageReport.maxUsagePerAccount(this.props.app.currentAccount(), 'minutes', 'peer'),
      planUsage = planMinutesInMilliseconds / (60 * 1000 * 1000),
      peerMilliseconds = model.get('peerMilliseconds');

    _.each(ltm, function(month){
      var monthlyUsage = peerMilliseconds[month.format] / (60 * 1000 * 1000);
      var dateString = ('0' + (month.date.getMonth()+1)).slice(-2) + " / " + month.date.getFullYear();
      data.push([dateString, humanizeNumber(monthlyUsage, 1), monthlyUsage, planUsage]);
    });

    var options = {
      vAxis: {title: "Minutes (thousand)"},
      hAxis: {title: "Month"},
      seriesType: "bars",
      legend: {position: 'none'},
      series: {1: {type: "line"}}
    };
    console.log("rendering chart", data)
    var chart = new google.visualization.ComboChart(this.refs['chartDiv'].getDOMNode());
    chart.draw(google.visualization.arrayToDataTable(data), options);
  },
  render: function(){
    return (<div ref="chartDiv" />);
  }
});
