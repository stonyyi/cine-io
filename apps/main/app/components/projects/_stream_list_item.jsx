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
            <dl>
            <dt>RTMP:</dt>
            <dd>{model.get('play').rtmp}</dd>
            <dt>HLS:</dt>
            <dd>{model.get('play').hls}</dd>
            </dl>
          </div>
          <div className="small-4 columns">
            <dl>
            <dt>Stream:</dt>
            <dd>{model.get('publish').stream}</dd>
            <dt>FMS url:</dt>
            <dd>{model.get('publish').url}</dd>
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
