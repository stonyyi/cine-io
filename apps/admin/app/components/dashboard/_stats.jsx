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
    var usageStats, accounts,
    splitByProvider, splitByPlan, splitByProviderHtml, splitByPlanHtml,
    model = this.props.model,
    accounts = model.getSortedUsage('bandwidth');

    splitByProvider = _.countBy(accounts, function(account) {return account.get('billingProvider')})
    splitByPlan = _.countBy(accounts, function(account) {return account.firstPlan()})
    splitByProviderHtml = _.map(splitByProvider, function(number, provider){
      return (<tr key={provider}>
        <td>{provider}</td>
        <td>{number}</td>
        </tr>)
    });

    splitByPlanHtml = _.map(splitByPlan, function(number, plan){
      return (<tr key={plan}>
        <td>{plan}</td>
        <td>{number}</td>
        </tr>)
    });

    usageStats = _.map(accounts, function(account){
      var
        name = account.get('name') || account.get('billingEmail'),
        usage = account.get('usage');
      return (<tr key={account.id}>
        <td>{name}</td>
        <td>{account.get('billingEmail')}</td>
        <td>{account.get('billingProvider')}</td>
        <td>{account.firstPlan()}</td>
        <td>{humanizeBytes(usage.bandwidth)}</td>
        <td>{humanizeBytes(usage.storage)}</td>
        </tr>)
    })
    return (
      <div id='admin-dashboard-show'>
        <h3>Usage Stats</h3>
        <table>
          <thead>
            <tr>
              <th>Name</th>
              <th>Email</th>
              <th>Provider</th>
              <th>Plan</th>
              <th>Bandwidth</th>
              <th>Storage</th>
            </tr>
          </thead>
          <tbody>
            {usageStats}
          </tbody>
          <tfoot>
            <tr>
            <td>Total</td>
            <td colSpan="3">{accounts.length} accounts</td>
            <td>{humanizeBytes(model.total('bandwidth'))}</td>
            <td>{humanizeBytes(model.total('usage'))}</td>
            </tr>
          </tfoot>
        </table>
        <table>
          <thead>
            <tr>
              <th>Plan</th>
              <th># accounts</th>
            </tr>
          </thead>
          <tbody>
            {splitByPlanHtml}
          </tbody>
        </table>
        <table>
          <thead>
            <tr>
              <th>Provider</th>
              <th># accounts</th>
            </tr>
          </thead>
          <tbody>
            {splitByProviderHtml}
          </tbody>
        </table>
      </div>
    );
  }
});
