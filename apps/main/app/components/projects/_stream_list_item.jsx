/** @jsx React.DOM */
var
  React = require('react'),
  Stream = Cine.model('stream');

module.exports = React.createClass({
  mixins: [Cine.lib('backbone_mixin')],
  propTypes: {
    model: React.PropTypes.instanceOf(Stream).isRequired
  },

  getBackboneObjects: function(){
    return this.props.model;
  },

  deleteProject: function (e) {
    e.preventDefault();
    alert('Not implemented');
  },
  render: function() {
    var model = this.props.model;
    return (
      <li>
        <div className='row'>
          <div className="small-4 columns">
            {model.get('streamName')}
          </div>
          <div className="small-4 columns">
            <dl>
            <dt>Stream:</dt>
            <dd>{model.get('streamName')}?{model.get('streamKey')}&amp;adbe-live-event={model.get('eventName')}</dd>
            <dt>FMS url:</dt>
            <dd>rtmp://stream.lax.cine.io/20C45E/{model.get('instanceName')}</dd>
            </dl>
          </div>
          <div className="small-1 columns">
            <a href='' onClick={this.deleteProject}><i className="fa fa-trash-o" /></a>
          </div>
        </div>
      </li>
    );
  }
});
