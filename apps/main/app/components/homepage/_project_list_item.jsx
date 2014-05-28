/** @jsx React.DOM */
var
  React = require('react'),
  Project = Cine.model('project');

module.exports = React.createClass({
  displayName: 'ProjectListItem',
  mixins: [Cine.lib('backbone_mixin')],
  propTypes: {
    model: React.PropTypes.instanceOf(Project).isRequired
  },
  getInitialState: function() {
    return {showApiKey: false};
  },

  getBackboneObjects: function(){
    return this.props.model;
  },
  deleteProject: function (e) {
    e.preventDefault();
    alert('Not implemented');
  },
  toggleApiKey: function (e) {
    e.preventDefault();
    this.setState({showApiKey: !this.state.showApiKey});
  },
  render: function() {
    var model = this.props.model,
    showKeyStyle = {},
    keyStyle = {display: 'none'};
    if (this.state.showApiKey){
      keyStyle = {};
      showKeyStyle = {display: 'none'};
    }
    var url = "/project/"+model.get('publicKey');
    return (
      <li>
        <div className='row'>
          <div className="small-4 columns">
            <a href={url}>{model.get('name')}</a>
          </div>
          <div className="small-4 columns">
            <div style={showKeyStyle}>
              <a href='' onClick={this.toggleApiKey}>Show public key</a>
            </div>
            <div style={keyStyle}>
              {model.get('publicKey')} <a href='' onClick={this.toggleApiKey}>hide</a>
            </div>
          </div>
          <div className="small-2 columns">
            {model.get('plan')}
          </div>
          <div className="small-1 columns">
            <a href='' onClick={this.deleteProject}><i className="fa fa-trash-o" /></a>
          </div>
        </div>
      </li>
    );
  }
});
