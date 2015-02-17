/** @jsx React.DOM */
var
  React = require('react'),
  _ = require('underscore'),
  Stats = Cine.model('stats'),
  humanizeBytes = Cine.lib('humanize_bytes'),
  humanizeTime = Cine.lib('humanize_time'),
  ProvidersAndPlans = Cine.require('config/providers_and_plans'),
  humanizeNumber = Cine.lib('humanize_number')
;

var isPayingCustomer = function(account){
  // are cine accounts
  // not disabled
  // not cannot be disabled (ie the cine accounts)
  // have a stripe card
  if (account.isDisabled()){
    return false;
  }
  if (account.get('cannotBeDisabled')){
    return false;
  }
  if (account.isCine()){
    return account.get('stripeCard') != null
  }
  // for now assume nobody is paying who is not a cine.io customer
  return false;
  // return account.firstPlan() != 'free' && account.firstPlan() != 'test'
}

module.exports = React.createClass({
  displayName: 'DashboardStats',
  getInitialState: function(){
    return {selectedMonth: this.props.model.getUsageMonths()[0]}
  },
  propTypes:{
    model: React.PropTypes.instanceOf(Stats).isRequired
  },
  changeMonth: function(month){
    this.setState({selectedMonth: month});
  },
  render: function() {
    var usageStats, accounts,
    splitByPlan, splitByPlanAndIsPaying, splitByProvider, splitByPlanHtml, splitByPlanAndIsPayingHtml, splitByProviderHtml
    self = this,
    model = this.props.model,
    selectedMonth = this.state.selectedMonth,
    accounts = model.getSortedUsage('bandwidth', selectedMonth);

    splitByProvider = _.countBy(accounts, function(account) {return account.get('provider')})
    splitByPlan = _.countBy(accounts, function(account) {return account.firstPlan()})

    splitByPlanAndIsPaying = _.chain(accounts).select(isPayingCustomer).countBy(function(account) {
      return account.firstPlan()
    }).value();

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
    var revenueTotal = 0;
    var payingCustomerTotal = 0;
    splitByPlanAndIsPayingHtml = _.map(splitByPlanAndIsPaying, function(number, plan){
      var
        planCost = ProvidersAndPlans['cine.io'].broadcast.plans[plan].price,
        revenue = number * planCost;
      payingCustomerTotal += number;
      revenueTotal += revenue;
      return (<tr key={plan}>
        <td>{plan}</td>
        <td>{number}</td>
        <td>${humanizeNumber(revenue)}</td>
        </tr>)
    });

    var totalPaying = (
      <tr key="total">
        <td>Total</td>
        <td>{humanizeNumber(payingCustomerTotal)}</td>
        <td>${humanizeNumber(revenueTotal)}</td>
      </tr>
    );

    splitByPlanAndIsPayingHtml.push(totalPaying);

    usageStats = _.map(accounts, function(account){
      var
        name = account.get('name') || account.get('billingEmail'),
        usage = account.get('usage');
      return (<tr key={account.id}>
        <td>{name}</td>
        <td>{account.get('email')}</td>
        <td>{isPayingCustomer(account)}</td>
        <td>{account.get('provider')}</td>
        <td>{account.firstPlan()}</td>
        <td>{humanizeBytes(usage.bandwidth)}</td>
        <td>{humanizeBytes(usage.storage)}</td>
        <td>{humanizeTime(usage.peerMilliseconds)}</td>
        </tr>)
    });
    monthSelector = _.map(model.getUsageMonths(), function(month){
      var inside
      if (month === selectedMonth){
        inside = month;
      }else{
        inside = (<a onClick={self.changeMonth.bind(this, month)}> {month} </a>);
      }
      return (<li key={month}>{inside}</li>)
    })
    return (
      <div id='admin-dashboard-show'>
        <h3>Usage Stats</h3>
        <ul className="inline-list">
          {monthSelector}
        </ul>
        <table>
          <thead>
            <tr>
              <th>Name</th>
              <th>Email</th>
              <th>Paying</th>
              <th>Provider</th>
              <th>Plan</th>
              <th>Bandwidth</th>
              <th>Storage</th>
              <th>Peer Talk Time</th>
            </tr>
          </thead>
          <tbody>
            {usageStats}
          </tbody>
          <tfoot>
            <tr>
            <td>Total</td>
            <td colSpan="3">{accounts.length} accounts</td>
            <td>{humanizeBytes(model.total('bandwidth', selectedMonth))}</td>
            <td>{humanizeBytes(model.total('storage', selectedMonth))}</td>
            </tr>
          </tfoot>
        </table>
        Paying cine accounts:
        <table>
          <thead>
            <tr>
              <th>Plan</th>
              <th># accounts</th>
              <th>Revenue</th>
            </tr>
          </thead>
          <tbody>
            {splitByPlanAndIsPayingHtml}
          </tbody>
        </table>
        Total plans:
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
