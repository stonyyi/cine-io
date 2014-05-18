/** @jsx React.DOM */
var
  React = require('react'),
  Project = Cine.model('project');

module.exports = React.createClass({
  mixins: [Cine.lib('backbone_mixin')],
  propTypes: {
    model: React.PropTypes.instanceOf(Project)
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
    return (
      <li>
        <div className='row'>
          <div className="small-4 columns">
            {model.get('name')}
          </div>
          <div className="small-4 columns">
            <div style={showKeyStyle}>
              <a href='' onClick={this.toggleApiKey}>Show api key</a>
            </div>
            <div style={keyStyle}>
              {model.get('apiKey')} <a href='' onClick={this.toggleApiKey}>hide</a>
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
