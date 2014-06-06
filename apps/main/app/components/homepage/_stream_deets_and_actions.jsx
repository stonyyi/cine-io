/** @jsx React.DOM */
var
  React = require('react'),
  Stream = Cine.model('stream'),
  Project = Cine.model('project');

module.exports = React.createClass({
  displayName: 'StreamDeetsAndActions',
  mixins: [Cine.lib('backbone_mixin')],
  propTypes: {
    model: React.PropTypes.instanceOf(Stream).isRequired,
    project: React.PropTypes.instanceOf(Project).isRequired
  },
  getBackboneObjects: function(){
    return this.props.model;
  },
  actuallyDestroyStream: function(){
    var self = this,
      secretKey = this.props.project.get('secretKey');
    this.props.model.attributes.secretKey = secretKey;
    this.props.model.destroy({
      data: {
        secretKey: secretKey
      },
      processData: true,
      wait: true,
      success: function(model, response){
        self.props.project.set('streamsCount', self.props.project.get('streamsCount')-1);
      }
    });
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
        <button className='button tiny alert' onClick={this.actuallyDestroyStream}>Delete</button>
      </div>
    );
  }
});
