/** @jsx React.DOM */
var
  React = require('react'),
  Stats = Cine.component('dashboard/_stats', 'admin')
;

module.exports = React.createClass({
  displayName: 'DashboardShow',
  mixins: [Cine.lib('requires_app')],
  render: function() {
    return (
      <div id='admin-dashboard-show'>
        <h1>The admin site</h1>
        <Stats model={this.props.model} />
      </div>
    );
  }
});
