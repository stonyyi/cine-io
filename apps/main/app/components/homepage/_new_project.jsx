/** @jsx React.DOM */
var
  React = require('react'),
  qs = require('qs'),
  Project = Cine.model('project'),
  Projects = Cine.collection('projects'),
  _ = require('underscore');

module.exports = React.createClass({
  displayName: 'NewProject',
  mixins: [Cine.lib('requires_app')],
  propTypes: {
    projects: React.PropTypes.instanceOf(Projects).isRequired
  },
  getInitialState: function() {
    return {value: ''};
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
        self.props.projects.add(model);
        self.setState({projectName: '', projectPlan: 'free'});
      }
    });
  },
  changeProjectName: function(event) {
    this.setState({projectName: event.target.value});
  },
  changeProjectPlan: function(event) {
    this.setState({projectPlan: event.target.value});
  },

  render: function() {
    var
      projectName = this.state.projectName,
      projectPlan = this.state.projectPlan,

      planOptions = _.map(Project.plans, function(plan) {
        var capitalized = plan.charAt(0).toUpperCase() + plan.slice(1);
        return (<option key={plan} value={plan}>{capitalized}</option>);
      });

    return (
      <form onSubmit={this.createProject}>
        <h3> New Project </h3>
        <div className="row">
          <div className="small-3 columns">
            <label htmlFor="project-name" className="right inline">Project Name</label>
          </div>
          <div className="small-9 columns">
            <input type="text" id="project-name" name='project[name]' value={projectName} onChange={this.changeProjectName} placeholder="My Fun Project (Production)" />
          </div>
        </div>
        <div className="row">
          <div className="small-3 columns">
            <label htmlFor="project-plan" className="right inline">Project Plan</label>
          </div>
          <div className="small-9 columns">
            <select value={projectPlan} onChange={this.changeProjectPlan} id='project-plan' name='project[plan]'>
              {planOptions}
            </select>
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
