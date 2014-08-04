/** @jsx React.DOM */
var React = require('react'),
Header = Cine.component('layout/header'),
Footer = Cine.component('layout/footer'),
LeftNav = Cine.component('layout/left_nav'),
FlashHolder = Cine.component('layout/flash_holder'),
humanizeBytes = Cine.lib('humanize_bytes'),
UsageReport = Cine.model('usage_report'),
_ = require('underscore');

var UsageGraph = React.createClass({
  displayName: "UsageGraph",
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
      planUsageInBytes = UsageReport.maxUsagePerAccount(this.props.app.currentUser),
      formatString = humanizeBytes.formatString(planUsageInBytes),
      planUsage = planUsageInBytes / humanizeBytes[formatString];

    _.each(ltm, function(month){
      var monthlyUsage = model.get(month.format) / humanizeBytes[formatString];
      var dateString = ('0' + (month.date.getMonth()+1)).slice(-2) + " / " + month.date.getFullYear();
      data.push([dateString, humanizeBytes(model.get(month.format)), monthlyUsage, planUsage]);
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
module.exports = React.createClass({
  displayName: 'UsageReportsShow',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin'), Cine.lib('has_nav')],
  getBackboneObjects: function(){
    return this.props.model;
  },
  render: function() {
    return (
      <div className={this.canvasClasses()}>
        <FlashHolder app={this.props.app}/>
        <div className="inner-wrap">
          <LeftNav app={this.props.app} showing={this.state.showingLeftNav}/>
          <Header app={this.props.app} />
          <div className='row'>
            <div className='small-12 columns'>
              <h1>Usage Report</h1>
              <UsageGraph model={this.props.model} app={this.props.app}/>
            </div>
          </div>
        </div>
        <Footer />
      </div>
    );
  }
});
