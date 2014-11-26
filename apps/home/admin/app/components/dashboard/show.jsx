/** @jsx React.DOM */
var
  React = require('react'),
  Stats = Cine.component('dashboard/_stats', 'admin')
  ThrottledAccounts = Cine.component('dashboard/_throttled_accounts', 'admin')
;

module.exports = React.createClass({
  displayName: 'DashboardShow',
  mixins: [Cine.lib('requires_app')],
  render: function() {
    return (
      <div id='admin-dashboard-show'>
        <h1>The admin site</h1>
        <Stats model={this.props.model} />
        <ThrottledAccounts collection={this.props.collection} />
      </div>
    );
  }
});
