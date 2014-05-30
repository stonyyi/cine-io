/** @jsx React.DOM */
var
  React = require('react'),
  NewProject = Cine.component('homepage/_new_project'),
  ListItem = Cine.component('homepage/_project_list_item'),
  Projects = Cine.collection('projects'),
  ProjectStreamsWrapper = Cine.component('homepage/_project_streams_wrapper');

module.exports = React.createClass({
  displayName: 'LoggedIn',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin')],
  propTypes: {
    collection: React.PropTypes.instanceOf(Projects).isRequired
  },
  getInitialState: function(){
    return {selectedProjectId: null};
  },
  componentDidMount: function() {
    this.props.collection.fetch();
  },
  getBackboneObjects: function(){
    return this.props.collection;
  },
  showCreateNewProject: function(e){
    e.preventDefault();
    alert('new project not implemented');
  },
  selectProject: function(project){
    this.setState({selectedProjectId: project.id});
  },
  render: function() {
    var selectedProjectId = this.state.selectedProjectId;
    // if nothing is selected, and we have a project, default select the first item
    if(!selectedProjectId && this.props.collection.length > 0){
      selectedProjectId = this.props.collection.models[0].id;
    }
    var
      createNewProjectButton = ''
      , streamsPanel = ''
      , listItems = this.props.collection.map(function(model) {
        var selected = model.id === selectedProjectId;
        return (<ListItem key={model.cid} model={model} selected={selected}/>);
      });
    if (this.props.collection.length > 0){
      createNewProjectButton = (
        <a href='' className='right' onClick={this.addNewProject}>
          <span className="fa-stack fa-lg">
            <i className="fa fa-square fa-stack-2x"></i>
            <i className="fa fa-plus fa-stack-1x fa-inverse"></i>
          </span>
        </a>
      );
    }
    if (selectedProjectId){
      var selectedProject = this.props.collection.get(selectedProjectId);
      streamsPanel = (<ProjectStreamsWrapper app={this.props.app} model={selectedProject} />);
    }
    return (
      <div>
        <div className='row'>
          <div className='medium-8 columns'>
            <div className="panels-wrapper panel">
              <div className='panel-heading clearfix'>
                <h3> Projects </h3>
                {createNewProjectButton}
              </div>
              <table className='clickable-row'>
                <thead>
                  <tr>
                    <th width='500'> Name </th>
                    <th width='30'> Plan </th>
                    <th width='60'> Actions </th>
                  </tr>
                </thead>
                <tbody>
                  {listItems}
                </tbody>
              </table>
            </div>
          </div>
          <div className='medium-4 columns'>
            DOCS HERE YO
          </div>
        </div>
        {streamsPanel}
        <div className="panel">
          <NewProject app={this.props.app} projects={this.props.collection}/>
        </div>
      </div>
    );
  }
});
