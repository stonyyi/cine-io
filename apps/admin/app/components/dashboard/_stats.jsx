/** @jsx React.DOM */
var
  React = require('react'),
  _ = require('underscore'),
  Stats = Cine.model('stats'),
  humanizeBytes = Cine.lib('humanize_bytes')
;

module.exports = React.createClass({
  displayName: 'DashboardStats',
  propTypes:{
    model: React.PropTypes.instanceOf(Stats).isRequired
  },
  render: function() {
    var month, monthName, usageStats;
    monthName = this.props.model.get('usageMonthName');
    usageStats = _.map(this.props.model.getSortedUsage(), function(account){
      console.log("this account", account)
      var name = account.get('name') || account.get('billingEmail');
      return (<tr key={account.id}>
        <td>{name}</td>
        <td>{account.get('billingProvider')}</td>
        <td>{humanizeBytes(account.get('usage'))}</td>
        </tr>)
    })
    return (
      <div id='admin-dashboard-show'>
        <h3>Usage Stats - {monthName}</h3>
        <table>
          <thead>
            <tr>
              <th>Name</th>
              <th>Provider</th>
              <th>Usage</th>
            </tr>
          </thead>
          <tbody>
          {usageStats}
          </tbody>
        </table>
      </div>
    );
  }
});
