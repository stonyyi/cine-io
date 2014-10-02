/** @jsx React.DOM */
var
  React = require('react'),
  humanizeBytes = Cine.lib('humanize_bytes'),
  UsageReport = Cine.model('usage_report'),
  _ = require('underscore');

module.exports = React.createClass({
  displayName: "Storage",
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin')],
  getBackboneObjects: function(){
    return this.props.model;
  },
  render: function(){
    var storageUsage = humanizeBytes(this.props.model.get('storage'));
    return (
      <div>
        <p>Current storage: {storageUsage}.</p>
      </div>
    );
  }
});
