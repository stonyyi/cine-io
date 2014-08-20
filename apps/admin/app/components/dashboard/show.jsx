/** @jsx React.DOM */
var React = require('react');

module.exports = React.createClass({
  displayName: 'DashboardShow',
  mixins: [Cine.lib('requires_app')],
  render: function() {
    return (
      <div id='admin-dashboard-show'>
        The admin site
      </div>
    );
  }
});
