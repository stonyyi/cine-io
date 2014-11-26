/** @jsx React.DOM */
var
  React = require('react'),
  _ = require('underscore'),
  Accounts = Cine.collection('accounts'),
  humanizeBytes = Cine.lib('humanize_bytes')
;

module.exports = React.createClass({
  displayName: 'DashboardStats',
  propTypes:{
    collection: React.PropTypes.instanceOf(Accounts).isRequired
  },
  render: function() {
    var accounts = this.props.collection;
    var usageStats = accounts.map(function(account){
      var
        name = account.get('name') || account.get('billingEmail'),
        usage = account.get('usage');
      return (<tr key={account.id}>
        <td>{account.get('id')}</td>
        <td>{name}</td>
        <td>{account.get('email')}</td>
        <td>{account.get('provider')}</td>
        <td>{account.firstPlan()}</td>
        <td>{account.get('throttledAt')}</td>
        <td>{account.get('throttledReason')}</td>
        </tr>)
    })

    return (
      <div id='throttled-accounts'>
        <h3>Throttled Accounts</h3>
        <table>
          <thead>
            <tr>
              <th>Id</th>
              <th>Name</th>
              <th>Email</th>
              <th>Provider</th>
              <th>Plan</th>
              <th>throttledAt</th>
              <th>throttledReason</th>
            </tr>
          </thead>
          <tbody>
            {usageStats}
          </tbody>
          <tfoot>
            <tr>
            <td>Total</td>
            <td colSpan="3">{accounts.length} accounts</td>
            </tr>
          </tfoot>
        </table>
      </div>
    );
  }
});
