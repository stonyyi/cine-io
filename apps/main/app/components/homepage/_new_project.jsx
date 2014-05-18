/** @jsx React.DOM */
var
  React = require('react'),
  qs = require('qs'),
  Project = Cine.model('project'),
  Projects = Cine.collection('projects');

module.exports = React.createClass({
  mixins: [Cine.lib('requires_app')],
  propTypes: {
    projects: React.PropTypes.instanceOf(Projects)
  },
  getInitialState: function() {
    return {value: ''};
  },
  createProject: function (e) {
    e.preventDefault();
    var self = this,
      form = jQuery(e.currentTarget),
      data = qs.parse(form.serialize()),
      p = new Project(data.project, {app: this.props.app});
    p.save(null, {
      success: function(model, response, options){
        self.props.projects.add(model);
        self.setState({value: ''});
      }
    });
  },
  handleChange: function(event) {
    this.setState({value: event.target.value});
  },

  render: function() {
    var value = this.state.value;
    return (
      <form onSubmit={this.createProject}>
        <h3> New Project </h3>
        <div className="row">
          <div className="small-3 columns">
            <label htmlFor="project-name" className="right inline">Project Name</label>
          </div>
          <div className="small-9 columns">
            <input type="text" id="project-name" name='project[name]' value={value} onChange={this.handleChange} placeholder="My Fun Project (Production)" />
          </div>
        </div>
        <div className="row">
          <div className="small-3 columns">
            <label htmlFor="project-plan" className="right inline">Project Plan</label>
          </div>
          <div className="small-9 columns">
            <select name='project-plan'>
              <option value="free">Free</option>
              <option value="developer">Developer</option>
              <option value="enterprise">Enterprise</option>
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
