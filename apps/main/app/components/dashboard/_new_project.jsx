/** @jsx React.DOM */
var
  React = require('react'),
  SubmitButton = Cine.component('shared/_submit_button'),
  qs = require('qs'),
  Project = Cine.model('project'),
  _ = require('underscore');

module.exports = React.createClass({
  displayName: 'NewProject',
  mixins: [Cine.lib('requires_app')],
  propTypes: {
    masterKey: React.PropTypes.string.isRequired
  },
  getInitialState: function() {
    return {submitting: false};
  },
  componentDidMount: function(){
    this.refs.projectName.getDOMNode().focus();
  },
  createProject: function (e) {
    e.preventDefault();
    if(this.state.submitting){return;}
    this.setState({submitting: true});
    var self = this,
      form = jQuery(e.currentTarget),
      data = qs.parse(form.serialize()),
      projectAttrs = data.project;
    projectAttrs.createStream = true;
    projectAttrs.masterKey = this.props.masterKey;
    var p = new Project(projectAttrs, {app: this.props.app});
    p.save(null, {
      success: function(model, response, options){
        if (self.isMounted()){ self.setState({submitting: false}); }
        self._owner.addProject(model);
      },
      error: function(model, response, options){
        if (self.isMounted()){ self.setState({submitting: false}); }
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
          <div className="small-6 columns">
            <input type="text" ref='projectName' id="project-name" name='project[name]' value={projectName} onChange={this.changeProjectName} placeholder="My Fun Project (Production)" />
          </div>
          <div className="small-3 columns">
            <SubmitButton className="button radius tiny" text="Create" submittingText="Creating" submitting={this.state.submitting}/>
          </div>
        </div>
      </form>
    );
  }
});
