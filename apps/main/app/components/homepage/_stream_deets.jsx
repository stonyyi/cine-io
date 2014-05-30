/** @jsx React.DOM */
var
  React = require('react'),
  Stream = Cine.model('stream');

module.exports = React.createClass({
  displayName: 'StreamDeets',
  mixins: [Cine.lib('backbone_mixin')],
  propTypes: {
    model: React.PropTypes.instanceOf(Stream).isRequired
  },
  getBackboneObjects: function(){
    return this.props.model;
  },
  render: function(){
    var model = this.props.model;
    return (
      <div className="panel">
        <div>{model.id}</div>
        <div>{model.assignedAt().toString()}</div>
        <dl>
          <dt>RTMP:</dt>
          <dd>{model.get('play').rtmp}</dd>
          <dt>HLS:</dt>
          <dd>{model.get('play').hls}</dd>
        </dl>
        <hr/>
        <dl>
          <dt>Stream:</dt>
          <dd>{model.get('publish').stream}</dd>
          <dt>FMS url:</dt>
          <dd>{model.get('publish').url}</dd>
        </dl>
      </div>
    );
  }


});
