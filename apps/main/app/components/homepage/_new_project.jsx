/** @jsx React.DOM */
var
  React = require('react'),
  qs = require('qs'),
  Project = Cine.model('project'),
  _ = require('underscore');

module.exports = React.createClass({
  displayName: 'NewProject',
  mixins: [Cine.lib('requires_app')],
  getInitialState: function() {
    return {};
  },
  componentDidMount: function(){
    this.refs.projectName.getDOMNode().focus();
  },
  createProject: function (e) {
    e.preventDefault();
    var self = this,
      form = jQuery(e.currentTarget),
      data = qs.parse(form.serialize()),
      projectAttrs = data.project;
    projectAttrs.createStream = true;
    var p = new Project(projectAttrs, {app: this.props.app});
    p.save(null, {
      success: function(model, response, options){
        self._owner.addProject(model);
      }
    });
  },
  changeProjectName: function(event) {
    this.setState({projectName: event.target.value});
  },
  render: function() {
    var
      projectName = this.state.projectName;
    return (
      <form onSubmit={this.createProject}>
        <div className="row">
          <div className="small-3 columns">
            <label htmlFor="project-name" className="right inline">Project Name</label>
          </div>
          <div className="small-9 columns">
            <input type="text" ref='projectName' id="project-name" name='project[name]' value={projectName} onChange={this.changeProjectName} placeholder="My Fun Project (Production)" />
          </div>
        </div>
        <div className="row">
          <div className="small-3 columns small-offset-3">
            <button type='submit'> Create Project </button>
          </div>
        </div>
      </form>
    );
  }
});
